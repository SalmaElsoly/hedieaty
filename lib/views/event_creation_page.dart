import 'package:flutter/material.dart';

import '../models/event.dart';
import '../shared/components/form.dart';
import '../controllers/event.dart';

class EventCreatePage extends StatefulWidget {
  final EventModel? event;

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

  late EventController _eventController = EventController.instance;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _eventDateController =
        TextEditingController(text: widget.event?.date ?? '');
    _eventNameController =
        TextEditingController(text: widget.event?.name ?? '');
    _eventLocationController =
        TextEditingController(text: widget.event?.location ?? '');
    _eventTimeController =
        TextEditingController(text: widget.event?.time ?? '');
    _eventDescriptionController =
        TextEditingController(text: widget.event?.description ?? '');
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventTimeController.dispose();
    _eventDescriptionController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _createEvent() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      final newEvent = EventModel(
        date: _eventDateController.text,
        name: _eventNameController.text,
        location: _eventLocationController.text,
        time: _eventTimeController.text,
        description: _eventDescriptionController.text,
      );
      await _eventController.createEvent(newEvent, context).then((value) {
        _isLoading.value = false;
        Navigator.of(context).pop(newEvent);
      });
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      final updatedEvent = EventModel(
        date: _eventDateController.text,
        name: _eventNameController.text,
        location: _eventLocationController.text,
        time: _eventTimeController.text,
        description: _eventDescriptionController.text,
        firestoreId: widget.event?.firestoreId,
        status: widget.event!.status,
      );
      await _eventController.updateEvent(updatedEvent, context).then((value) {
        _isLoading.value = false;
        Navigator.of(context).pop(updatedEvent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.4),
              Colors.white
            ],
          ),
        ),
        height: screenHeight,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEditing ? 'Edit Your Event' : 'Plan Your Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),
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
                        label: 'Date',
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
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
                        label: 'Time',
                        prefix: Icons.access_time,
                        type: TextInputType.datetime,
                        readOnly: true,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 12, minute: 0),
                          );
                          if (time != null) {
                            String formattedTime =
                                "${time.hour}:${time.minute}";
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
                      SizedBox(height: 30),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoading,
                        builder: (context, isLoading, child) {
                          return defaultFormButton(
                            onPressed: isLoading
                                ? () {}
                                : (isEditing ? _saveEvent : _createEvent),
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    isEditing ? 'Save Changes' : 'Create Event',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            screenWidth: screenWidth,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
