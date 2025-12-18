import 'package:flutter/material.dart';

Widget statusChip(String? status) {
  switch (status) {
    case 'approved':
      return const Chip(
        label: Text('APPROVED', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      );
    case 'rejected':
      return const Chip(
        label: Text('REJECTED', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      );
    default:
      return const Chip(
        label: Text('PENDING', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      );
  }
}
