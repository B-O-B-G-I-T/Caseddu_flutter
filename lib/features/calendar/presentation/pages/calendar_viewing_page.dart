import 'package:flutter/material.dart';

import '../widgets/calendar_widget.dart';
import 'event_editing_page.dart';

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
