import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devrev_sdk_flutter/devrev.dart';
import 'dart:io';
import 'dart:developer' as developer;

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  final List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    DevRev.trackScreenName("Gallery");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => image.path).toList());
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${images.length} image(s) selected from Gallery')),
          );
        }
        developer.log("Gallery Images Selected: ${images.length}");
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No images selected')),
          );
        }
      }
    } catch (e) {
      developer.log("Error picking images", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error selecting images')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          if (_selectedImages.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_selectedImages.length} ${_selectedImages.length == 1 ? 'photo' : 'photos'}',
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImages.isEmpty
                ? const SizedBox.expand()
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final imagePath = _selectedImages[index];
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: DevRevMask(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  File(imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Select Photos'),
                  ),
                ),
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.delete),
                    label: const Text('Clear'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
