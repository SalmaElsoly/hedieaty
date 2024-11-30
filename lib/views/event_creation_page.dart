import 'package:flutter/material.dart';

import '../shared/components/form.dart';

class EventCreatePage extends StatefulWidget {
  final Map<String, dynamic>? event;

  const EventCreatePage({super.key, this.event});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventDateController;
  late TextEditingController _eventNameController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventTimeController;
  late TextEditingController _eventDescriptionController;

  @override
  void initState() {
    super.initState();
    _eventDateController =
        TextEditingController(text: widget.event?['date'] ?? '');
    _eventNameController =
        TextEditingController(text: widget.event?['name'] ?? '');
    _eventLocationController =
        TextEditingController(text: widget.event?['location'] ?? '');
    _eventTimeController =
        TextEditingController(text: widget.event?['time'] ?? '');
    _eventDescriptionController =
        TextEditingController(text: widget.event?['description'] ?? '');
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventTimeController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = {
        'id': widget.event?['id'] ?? DateTime.now().millisecondsSinceEpoch,
        'date': _eventDateController.text,
        'name': _eventNameController.text,
        'location': _eventLocationController.text,
        'time': _eventTimeController.text,
        'description': _eventDescriptionController.text,
      };
      Navigator.of(context).pop(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              defaultFormField(
                controller: _eventNameController,
                label: 'Event Name',
                hintText: 'Enter Event Name',
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
                prefix: Icons.event,
                type: TextInputType.name,
              ),
              SizedBox(height: 20),
              defaultFormField(
                controller: _eventDateController,
                label: 'Enter Date',
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
                prefix: Icons.calendar_today,
                type: TextInputType.datetime,
                readOnly: true,
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    String formattedDate =
                        "${date.day}-${date.month}-${date.year}";
                    setState(() {
                      _eventDateController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              defaultFormField(
                controller: _eventTimeController,
                label: 'Enter Time',
                prefix: Icons.access_time,
                type: TextInputType.datetime,
                readOnly: true,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter time';
                  }
                  return null;
                },
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 12, minute: 0),
                  );
                  if (time != null) {
                    String formattedTime = "${time.hour}:${time.minute}";
                    setState(() {
                      _eventTimeController.text = formattedTime;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              defaultFormField(
                controller: _eventLocationController,
                label: 'Event Location',
                prefix: Icons.location_on,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                type: TextInputType.text,
              ),
              SizedBox(height: 20),
              defaultFormField(
                controller: _eventDescriptionController,
                label: 'Event Description',
                prefix: Icons.description,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                type: TextInputType.text,
              ),
              SizedBox(height: 20),
              defaultFormButton(
                onPressed: isEditing ? _saveEvent : _createEvent,
                child: Text(isEditing ? 'Save Changes' : 'Create Event'),
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
