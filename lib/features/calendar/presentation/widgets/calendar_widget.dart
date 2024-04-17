import 'package:caseddu/features/calendar/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../pages/event_editing_page.dart';
import '../../data/models/event_data_source.dart';
import '../providers/calendar_provider.dart';
import 'task_widget.dart';

class MyCalendar extends StatelessWidget {
  const MyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<EventEntity> events = Provider.of<CalendarProvider>(context).events;
    return Stack(
      children: [
        SfCalendar(
          view: CalendarView.month,
          dataSource: EventDataSource(events),
          firstDayOfWeek: 6,
          onLongPress: (details) {
            final provider =
                Provider.of<CalendarProvider>(context, listen: false);

            provider.setDate(details.date!);
            showModalBottomSheet(
              context: context,
              builder: (context) => const TasksWidget(),
            );
          },
        ),
        Positioned(
          top: 5,
          right: -15,
          child: MaterialButton(
            shape: const CircleBorder(),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EventEditing(),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }
}
