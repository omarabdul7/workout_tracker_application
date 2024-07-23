import 'package:flutter/material.dart';

List<Widget> buildDataList(List<MapEntry<String, num>> data) {
  return data.map((entry) {
    final label = entry.key;
    final value = entry.value;
    return ListTile(
      title: Text(label),
      trailing: Text(value.toString()),
    );
  }).toList();
}