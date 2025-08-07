import 'package:flutter/material.dart';

class StatusListItem extends StatelessWidget {
  final String title;
  final bool status;

  const StatusListItem({required this.title, required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Icon(
        status ? Icons.check_circle : Icons.circle_outlined,
      ),
    );
  }

  static Widget buildStatusListItem({required String title, required bool status}) {
    return StatusListItem(title: title, status: status);
  }
}
