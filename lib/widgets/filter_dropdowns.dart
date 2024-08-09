import 'package:flutter/material.dart';
import '../enums.dart';


Widget buildFilterDropdowns(
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  GroupBy selectedGroupBy,
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
  Function(GroupBy?) onGroupByChanged,
  BuildContext context,
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
              DropdownMenuItem(
                value: ViewType.volume,
                child: Text(
                  'Volume',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem(
                value: ViewType.sets,
                child: Text(
                  'Sets',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem(
                value: ViewType.oneRepMax,
                child: Text(
                  'One Rep Max',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          DropdownButton<TimeFrame>(
            value: selectedTimeFrame,
            onChanged: onTimeFrameChanged,
            items: [
              DropdownMenuItem(
                value: TimeFrame.last7Days,
                child: Text(
                  'Last 7 Days',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem(
                value: TimeFrame.lastMonth,
                child: Text(
                  'Last Month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              DropdownMenuItem(
                value: TimeFrame.lastYear,
                child: Text(
                  'Last Year',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 8),
      DropdownButton<GroupBy>(
        value: selectedGroupBy,
        onChanged: onGroupByChanged,
        items: [
          DropdownMenuItem(
            value: GroupBy.muscleGroup,
            child: Text(
              'By Muscle Group',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          DropdownMenuItem(
            value: GroupBy.exercise,
            child: Text(
              'By Exercise',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    ],
  );
}