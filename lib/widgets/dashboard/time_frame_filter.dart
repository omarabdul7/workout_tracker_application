import 'package:flutter/material.dart';
import '../../enums.dart';

class TimeFrameFilter extends StatelessWidget {
  final TimeFrame selectedTimeFrame;
  final Function(TimeFrame) onTimeFrameSelected;

  const TimeFrameFilter({
    super.key,
    required this.selectedTimeFrame,
    required this.onTimeFrameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildTimeFrameChip(context, TimeFrame.last7Days, 'Last 7 Days'),
          _buildTimeFrameChip(context, TimeFrame.lastMonth, 'Last Month'),
        ],
      ),
    );
  }

  Widget _buildTimeFrameChip(BuildContext context, TimeFrame timeFrame, String label) {
    final isSelected = selectedTimeFrame == timeFrame;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onTimeFrameSelected(timeFrame);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      showCheckmark: true,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
} 