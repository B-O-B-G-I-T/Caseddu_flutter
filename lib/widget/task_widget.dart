import 'package:flutter/material.dart';
import 'package:flutter_application_1/modeles/event_data_source.dart';
import 'package:flutter_application_1/provider/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../pages/calendar_pages/event_viewing_page.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final seletedEvents = provider.eventsSelectedDate;

    if (seletedEvents.isEmpty) {
      return const Center(
        child: Text("Pas d'événements"),
      );
    }
    return SfCalendarTheme(
      data: SfCalendarThemeData(),
      child: SfCalendar(
        view: CalendarView.timelineDay,
        headerHeight: 0,
        dataSource: EventDataSource(provider.events),
        initialDisplayDate: provider.selectedDate,
        appointmentBuilder: appointmentBuilder,
        onTap: (details) {
          if (details.appointments == null) return;
          final event = details.appointments!.first;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventViewingPage(event: event),
          ));
        },
      ),
    );
  }

  Widget appointmentBuilder(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final event = details.appointments.first;

    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: event.backgroundColor,
      ),
      child: Center(
        child: Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
