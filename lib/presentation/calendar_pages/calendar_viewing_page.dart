import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/calendar_pages/event_editing_page.dart';

import '../../widget/calendar_widget/calendar_widget.dart';

class CalendarViewingPage extends StatefulWidget {
  const CalendarViewingPage({super.key});

  @override
  State<CalendarViewingPage> createState() => _CalendarViewingPageState();
}

class _CalendarViewingPageState extends State<CalendarViewingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EventEditing(),
            ),
          ),
          icon: const Icon(Icons.add),
        ),
        title: const Text('Calendrier'),
      ),
      body: const MyCalendar(),
    );
  }
}
