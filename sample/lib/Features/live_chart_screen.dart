import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:devrev_sdk_flutter/devrev.dart';

const int _kWindowMs = 1 * 60 * 1000;

class StockItem {
  final String symbol;
  final String name;
  double price;
  double openPrice;

  StockItem(this.symbol, this.name, this.price, this.openPrice);
}

class PriceSample {
  final DateTime timestamp;
  final double price;
  const PriceSample(this.timestamp, this.price);
}

class RealTimeUpdatesScreen extends StatefulWidget {
  const RealTimeUpdatesScreen({super.key});

  @override
  State<RealTimeUpdatesScreen> createState() => RealTimeUpdatesScreenState();
}

class RealTimeUpdatesScreenState extends State<RealTimeUpdatesScreen> {
  static const List<Map<String, String>> _cryptoAssets = [
    {"symbol": "BTCUSDT", "name": "Bitcoin"},
    {"symbol": "ETHUSDT", "name": "Ethereum"},
    {"symbol": "BNBUSDT", "name": "BNB"},
    {"symbol": "SOLUSDT", "name": "Solana"},
    {"symbol": "ADAUSDT", "name": "Cardano"},
    {"symbol": "XRPUSDT", "name": "XRP"},
    {"symbol": "DOGEUSDT", "name": "Dogecoin"},
    {"symbol": "DOTUSDT", "name": "Polkadot"},
    {"symbol": "MATICUSDT", "name": "Polygon"},
    {"symbol": "LINKUSDT", "name": "Chainlink"},
    {"symbol": "AVAXUSDT", "name": "Avalanche"},
    {"symbol": "UNIUSDT", "name": "Uniswap"},
    {"symbol": "ATOMUSDT", "name": "Cosmos"},
    {"symbol": "LTCUSDT", "name": "Litecoin"},
    {"symbol": "TRXUSDT", "name": "TRON"},
  ];

  final Map<String, StockItem> _stocks = {};

  final Map<String, List<PriceSample>> _history = {};

  final ValueNotifier<List<FlSpot>> _chartDataNotifier = ValueNotifier([]);

  String _selectedSymbol = "BTCUSDT";
  String _searchQuery = "";
  int _updateCount = 0;

  WebSocketChannel? _channel;

  Timer? _chartThrottleTimer;
  bool _chartDirty = false;

  @override
  void initState() {
    super.initState();
    for (var asset in _cryptoAssets) {
      final sym = asset["symbol"]!;
      _stocks[sym] = StockItem(sym, asset["name"]!, 0.0, 0.0);
      _history[sym] = [];
    }

    _chartThrottleTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) {
      if (_chartDirty && mounted) {
        _chartDirty = false;
        _rebuildChartSpots();
      }
    });

    _connectWebSocket();
  }

  void _connectWebSocket() {
    final streams =
        _stocks.keys.map((e) => "${e.toLowerCase()}@trade").join("/");
    final url = "wss://stream.binance.com:9443/stream?streams=$streams";

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _safeTrack("websocket_start", {"status": "connecting", "api": "binance"});

    _channel!.stream.listen(
      _onMessage,
      onError: (e) {
        _safeTrack("websocket_error", {"error": e.toString()});
      },
    );
  }

  void _onMessage(dynamic raw) {
    final json = jsonDecode(raw.toString());
    final data = json['data'];
    if (data == null) return;

    final symbol = data['s'] as String;
    final price = double.tryParse(data['p'] as String) ?? 0.0;
    final now = DateTime.now();

    final stock = _stocks[symbol];
    if (stock != null) {
      if (stock.openPrice == 0.0) stock.openPrice = price;
      stock.price = price;
      if (mounted) setState(() {});
    }

    final samples = _history[symbol];
    if (samples != null) {
      samples.add(PriceSample(now, price));
      final cutoff = now.subtract(const Duration(milliseconds: _kWindowMs));
      samples.removeWhere((s) => s.timestamp.isBefore(cutoff));
    }
    if (symbol == _selectedSymbol) {
      _chartDirty = true;
    }

    _updateCount++;
  }

  void _rebuildChartSpots() {
    final samples = _history[_selectedSymbol] ?? [];
    if (samples.isEmpty) {
      _chartDataNotifier.value = [];
      return;
    }

    final spots = samples
        .map(
          (s) => FlSpot(s.timestamp.millisecondsSinceEpoch.toDouble(), s.price),
        )
        .toList();

    _chartDataNotifier.value = spots;
  }

  void _selectSymbol(String symbol) {
    if (symbol == _selectedSymbol) return;
    setState(() {
      _selectedSymbol = symbol;
    });
    _rebuildChartSpots();
  }

  void _safeTrack(String event, Map<String, String> data) {
    try {
      DevRev.trackEvent(event, data);
    } catch (_) {}
  }

  double _calculatePercent(double open, double current) {
    if (open == 0.0) return 0.0;
    return ((current - open) / open) * 100;
  }

  String _formatTime(double epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs.toInt());
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  @override
  void dispose() {
    _safeTrack("websocket_stop", {"total_updates": _updateCount.toString()});
    _chartThrottleTimer?.cancel();
    _channel?.sink.close();
    _chartDataNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStock = _stocks[_selectedSymbol]!;
    final filteredStocks = _stocks.values.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filteredStocks.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          selectedStock.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "\$${selectedStock.price.toStringAsFixed(selectedStock.price < 10 ? 4 : 2)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildChartSection(),
          _buildMarketWatchHeader(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredStocks.length,
              itemBuilder: (context, i) {
                final stock = filteredStocks[i];
                return _buildStockCard(stock);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return ValueListenableBuilder<List<FlSpot>>(
      valueListenable: _chartDataNotifier,
      builder: (context, chartData, child) {
        if (chartData.length < 2) {
          return const SizedBox(
            height: 280,
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          );
        }

        final prices = chartData.map((e) => e.y);
        final minY = prices.reduce((a, b) => a < b ? a : b);
        final maxY = prices.reduce((a, b) => a > b ? a : b);
        var range = maxY - minY;
        if (range == 0) range = 1.0;

        final now = DateTime.now().millisecondsSinceEpoch.toDouble();
        final windowStart = now - _kWindowMs;

        const labelInterval = _kWindowMs * 1.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: LineChart(
                LineChartData(
                  clipData: const FlClipData.all(),
                  minY: minY - (range * 0.1),
                  maxY: maxY + (range * 0.1),
                  minX: windowStart,
                  maxX: now,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withValues(alpha: 0.30),
                            Colors.blueAccent.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: labelInterval,
                        getTitlesWidget: (value, meta) {
                          final diff = (value - windowStart) % labelInterval;
                          if (diff > labelInterval * 0.05 &&
                              diff < labelInterval * 0.95) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatTime(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: false,
                    verticalInterval: labelInterval,
                    getDrawingVerticalLine: (_) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              "\$${s.y.toStringAsFixed(s.y < 10 ? 4 : 2)}\n${_formatTime(s.x)}",
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 0),
                curve: Curves.linear,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketWatchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Market Watch",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Search crypto...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockItem stock) {
    final pct = _calculatePercent(stock.openPrice, stock.price);
    final isUp = pct >= 0;
    final isSelected = stock.symbol == _selectedSymbol;

    return GestureDetector(
      onTap: () => _selectSymbol(stock.symbol),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue.shade200 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      stock.name[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.price == 0.0
                      ? "--"
                      : "\$${stock.price.toStringAsFixed(stock.price < 10 ? 4 : 2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${isUp ? '+' : ''}${pct.toStringAsFixed(2)}%",
                  style: TextStyle(
                    color: isUp ? Colors.green.shade600 : Colors.red.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
