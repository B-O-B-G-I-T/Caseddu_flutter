import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/calendar_pages/event_editing_page.dart';

import '../../widget/bottombar.dart';
import '../../widget/calendar_widget.dart';

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
              builder: (context) => EventEditing(),
            ),
          ),
          icon: Icon(Icons.add),
        ),
        title: Text('Calendrier'),
      ),
      body: MyCalendar(),
    );
  }
}
