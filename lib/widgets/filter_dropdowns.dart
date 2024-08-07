import 'package:flutter/material.dart';
import '../enums.dart';

Widget buildFilterDropdowns(
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  GroupBy selectedGroupBy,
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
  Function(GroupBy?) onGroupByChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<ViewType>(
            value: selectedViewType,
            onChanged: onViewTypeChanged,
            items: [
              DropdownMenuItem(value: ViewType.volume, child: Text('Volume')),
              DropdownMenuItem(value: ViewType.sets, child: Text('Sets')),
              DropdownMenuItem(value: ViewType.oneRepMax, child: Text('One Rep Max')),
            ],
          ),
          DropdownButton<TimeFrame>(
            value: selectedTimeFrame,
            onChanged: onTimeFrameChanged,
            items: [
              DropdownMenuItem(value: TimeFrame.last7Days, child: Text('Last 7 Days')),
              DropdownMenuItem(value: TimeFrame.lastMonth, child: Text('Last Month')),
              DropdownMenuItem(value: TimeFrame.lastYear, child: Text('Last Year')),
            ],
          ),
        ],
      ),
      SizedBox(height: 8),
      DropdownButton<GroupBy>(
        value: selectedGroupBy,
        onChanged: onGroupByChanged,
        items: [
          DropdownMenuItem(value: GroupBy.muscleGroup, child: Text('By Muscle Group')),
          DropdownMenuItem(value: GroupBy.exercise, child: Text('By Exercise')),
        ],
      ),
    ],
  );
}
