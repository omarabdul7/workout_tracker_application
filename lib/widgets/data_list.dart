import 'package:flutter/material.dart';

List<Widget> buildDataList(List<MapEntry<String, num>> sortedAggregatedData, String unit) {
  return sortedAggregatedData.map((entry) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(entry.key),
        Text('${entry.value.toStringAsFixed(1)} $unit'),
      ],
    ),
  )).toList();
}