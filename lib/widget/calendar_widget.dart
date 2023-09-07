import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/event_provider.dart';
import 'package:flutter_application_1/widget/task_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../pages/calendar_pages/event_editing_page.dart';
import '../modeles/event_data_source.dart';

class MyCalendar extends StatelessWidget {
  const MyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return Container(
      child: Stack(
        children: [
          SfCalendar(
            view: CalendarView.month,
            dataSource: EventDataSource(events),
            firstDayOfWeek: 6,
            onLongPress: (details) {
              final provider =
                  Provider.of<EventProvider>(context, listen: false);

              provider.setDate(details.date!);
              showModalBottomSheet(
                context: context,
                builder: (context) => TasksWidget(),
              );
            },
          ),
          Positioned(
            top: 5,
            right: -15,
            child: MaterialButton(
              shape: CircleBorder(),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventEditing(),
                ),
              ),
              child: Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }
}
