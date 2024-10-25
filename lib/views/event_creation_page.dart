import 'package:flutter/material.dart';

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
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.7),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _eventDateController,
                decoration: InputDecoration(
                    //icon of text field
                    labelText: "Enter Date", //label text of field
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary)),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .onSecondary
                        .withOpacity(0.7),
                    prefixIcon: Icon(Icons.calendar_today,
                        color: Theme.of(context).colorScheme.secondary)),
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
              TextField(
                controller: _eventTimeController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.access_time,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary), //icon of text field
                    labelText: "Enter Time", //label text of field
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary)),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .onSecondary
                        .withOpacity(0.7)),
                readOnly: true,
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
              TextFormField(
                controller: _eventLocationController,
                decoration: InputDecoration(
                  labelText: 'Event Location',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.7),
                  prefixIcon: Icon(Icons.location_on,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.7),
                  prefixIcon: Icon(Icons.description,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: isEditing ? _saveEvent : _createEvent,
                style: ButtonStyle(
                  minimumSize:
                      WidgetStatePropertyAll(Size(screenWidth * 0.8, 50)),
                ),
                child: Text(isEditing ? 'Save Changes' : 'Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
