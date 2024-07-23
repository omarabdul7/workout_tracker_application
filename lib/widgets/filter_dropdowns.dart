import 'package:flutter/material.dart';
import '../enums.dart';

Widget buildFilterDropdowns(
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
) {
  return Row(
    children: [
      DropdownButton<ViewType>(
        value: selectedViewType,
        onChanged: onViewTypeChanged,
        items: ViewType.values.map((ViewType viewType) {
          return DropdownMenuItem<ViewType>(
            value: viewType,
            child: Text(viewType.toString().split('.').last),
          );
        }).toList(),
      ),
      const SizedBox(width: 16),
      DropdownButton<TimeFrame>(
        value: selectedTimeFrame,
        onChanged: onTimeFrameChanged,
        items: TimeFrame.values.map((TimeFrame timeFrame) {
          return DropdownMenuItem<TimeFrame>(
            value: timeFrame,
            child: Text(timeFrame.toString().split('.').last),
          );
        }).toList(),
      ),
    ],
  );
}