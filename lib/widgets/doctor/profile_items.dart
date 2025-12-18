import 'package:flutter/material.dart';

Widget buildProfileItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

