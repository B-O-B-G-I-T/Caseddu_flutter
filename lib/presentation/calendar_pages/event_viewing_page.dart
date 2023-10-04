import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/calendar_pages/event_editing_page.dart';
import 'package:flutter_application_1/modeles/event.dart';
import 'package:flutter_application_1/provider/event_provider.dart';
import 'package:provider/provider.dart';

class EventViewingPage extends StatelessWidget {
  const EventViewingPage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: buildViewingActions(context, event),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            event.title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(
            height: 32,
          ),
          buildDateTime(context, event),
          const SizedBox(
            height: 32,
          ),
          Text(
            'Description :',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(event.description)
        ],
      ),
    );
  }

  Widget buildDateTime(BuildContext context, Event event) {
    return Column(
      children: [
        buildDate(context, 'From', event.from),
        buildDate(context, 'To', event.to)
      ],
    );
  }

  Widget buildDate(BuildContext context, String title, DateTime date) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(date.toString()),
        ],
      ),
    );
  }

  List<Widget> buildViewingActions(BuildContext context, Event event) {
    List<Widget> actions = [];
    actions.add(
      IconButton(
        icon: const Icon(Icons.edit_calendar_outlined),
        onPressed: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EventEditing(
              event: event,
            ),
          ),
        ),
      ),
    );

    actions.add(
      IconButton(
        icon: const Icon(Icons.delete_forever_outlined),
        onPressed: () {
          final provider = Provider.of<EventProvider>(context, listen: false);
          provider.deleteEvent(event);

          Navigator.of(context).pop();
        },
      ),
    );
    return actions;
  }
}