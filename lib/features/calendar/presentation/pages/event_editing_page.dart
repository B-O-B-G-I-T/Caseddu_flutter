import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/p2p/fonctions.dart';
import '../../domain/entities/event_entity.dart';
import '../providers/calendar_provider.dart';

class EventEditing extends StatefulWidget {
  final EventEntity? event;

  const EventEditing({Key? key, this.event}) : super(key: key);

  @override
  State<EventEditing> createState() => _EventEditingState();
}

class _EventEditingState extends State<EventEditing> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;
  late String recurrence;
  late String description;

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now().add(const Duration(hours: 1));
      recurrence = 'Jamais';
      description = '';
    } else {
      final event = widget.event!;
      titleController.text = event.title;
      fromDate = event.from;
      toDate = event.to;
      recurrence = event.recurrence;
      description = event.description;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          actions: buildEditingActions(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                buildTitle(),
                const SizedBox(
                  height: 20,
                ),
                buildDataTimePickers(),
                const SizedBox(
                  height: 20,
                ),
                buildRepliquer(),
                const SizedBox(
                  height: 20,
                ),
                buildDescription(),
              ],
            ),
          ),
        ),
      );

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
          icon: const Icon(Icons.done),
          label: const Text("Valide"),
          onPressed: saveForm,
        )
      ];
  Widget buildTitle() => TextFormField(
        decoration: const InputDecoration(
            border: UnderlineInputBorder(), hintText: 'Ajoute un titre'),
        validator: (title) =>
            title != null && title.isEmpty ? 'Il faut un titre' : null,
        onFieldSubmitted: (_) => saveForm(),
        controller: titleController,
      );

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildDataTimePickers() => Column(
        children: [
          buildForm(),
          buildTo(),
        ],
      );

  Widget buildForm() => buildHeader(
        header: 'FROM',
        child: Row(
          children: [
            Expanded(
              child: buildDropdownField(
                text: Utils.toDate(fromDate),
                onClicked: () => pickFromDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(fromDate),
                onClicked: () => pickFromDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Widget buildTo() => buildHeader(
        header: 'TO',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildDropdownField(
                text: Utils.toDate(toDate),
                onClicked: () => pickToDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                text: Utils.toTime(toDate),
                onClicked: () => pickToDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);

    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate =
          DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }
    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(
      toDate,
      pickDate: pickDate,
      firstDate: pickDate ? fromDate : null,
    );

    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate =
          DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }
    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,
  }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015, 8),
        lastDate: DateTime(2101),
      );

      if (date == null) return null;
      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (timeOfDay == null) return null;

      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
        onTap: onClicked,
      ); // ListTile

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: Theme.of(context).textTheme.titleLarge),
          child
        ],
      );

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = EventEntity(
        title: titleController.text,
        description: descriptionController.text,
        from: fromDate,
        to: toDate,
        recurrence: recurrence,
      );

      final isEditing = widget.event != null;
      final provider = Provider.of<CalendarProvider>(context, listen: false);

      if (isEditing) {
        provider.editEvent(event, widget.event!);
      } else {
        provider.addEvent(event);
      }

      Navigator.of(context).pop();
    }
  }

  Widget buildRepliquer() {
    List<String> listDesChoix = [
      'Jamais',
      'Tous les jours',
      'Tous les deux jours',
      'Tous les semaines',
      'Tous les mois',
      'Tous les ans'
    ];

    return Row(children: [
      Expanded(
        child:
            Text("Récurrence", style: Theme.of(context).textTheme.titleLarge),
      ),
      Expanded(
        child: DropdownButton(
          value: recurrence,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: listDesChoix.map((elu) {
            return DropdownMenuItem(value: elu, child: Text(elu));
          }).toList(),
          onChanged: (String? valeur) {
            recurrence = valeur.toString();
            setState(() {
              recurrence = recurrence;
            });
          },
        ),
      ),
    ]);
  }

  Widget buildDescription() {
    return buildHeader(
      header: "Description :",
      child: TextFormField(
        decoration: const InputDecoration(hintText: 'Faites une description'),
        validator: (texte) =>
            texte != null && texte.isEmpty ? 'Il faut un titre' : null,
        onFieldSubmitted: (_) => saveForm(),
        controller: descriptionController,
      ),
    );
  }
}
