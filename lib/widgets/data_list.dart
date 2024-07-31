import 'package:flutter/material.dart';

List<Widget> buildDataList(List<MapEntry<String, num>> data, String unit) {
  return [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        children: [
          TableRow(
            children: [
              Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ...data.map((entry) => TableRow(
            children: [
              Text(entry.key),
              Text('${entry.value.toStringAsFixed(1)} $unit'),
            ],
          )).toList(),
        ],
      ),
    ),
    SizedBox(height: 16),
  ];
}