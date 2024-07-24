import 'package:flutter/material.dart';
import '../enums.dart';

Widget buildFilterDropdowns(
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      DropdownButton<ViewType>(
        value: selectedViewType,
        onChanged: onViewTypeChanged,
        items: [
          DropdownMenuItem(
            value: ViewType.volume,
            child: Text('Volume'),
          ),
          DropdownMenuItem(
            value: ViewType.sets,
            child: Text('Sets'),
          ),
          DropdownMenuItem(
            value: ViewType.oneRepMax,
            child: Text('One Rep Max'),
          ),
        ],
      ),
      DropdownButton<TimeFrame>(
        value: selectedTimeFrame,
        onChanged: onTimeFrameChanged,
        items: [
          DropdownMenuItem(
            value: TimeFrame.week,
            child: Text('Week'),
          ),
          DropdownMenuItem(
            value: TimeFrame.month,
            child: Text('Month'),
          ),
          DropdownMenuItem(
            value: TimeFrame.year,
            child: Text('Year'),
          ),
        ],
      ),
    ],
  );
}