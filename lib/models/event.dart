import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final int? id;
  late final int? userId;
  late final String? firestoreId;
  final String name;
  final String date;
  final String time;
  final String location;
  final String description;
  final String status;
  final DateTime lastModified;
  final bool isDeleted;

  EventModel({
    this.id,
    this.userId,
    this.firestoreId,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.status = 'upcoming',
    DateTime? lastModified,
    this.isDeleted = false,
  })  : lastModified = lastModified ?? DateTime.now(),
        assert(status == 'upcoming' || status == 'current' || status == 'past');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'firestoreId': firestoreId,
      'name': name,
      'date': date,
      'time': time,
      'location': location,
      'description': description,
      'status': status,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      userId: map['userId'],
      firestoreId: map['firestoreId'],
      name: map['name'],
      date: map['date'],
      time: map['time'],
      location: map['location'],
      description: map['description'],
      status: map['status'],
      lastModified: DateTime.parse(map['lastModified']),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      firestoreId: doc.id,
      name: data['name'],
      date: data['date'],
      time: data['time'],
      location: data['location'],
      description: data['description'],
      status: data['status'],
      lastModified: DateTime.parse(data['lastModified']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': this.name,
      'date': this.date,
      'time': this.time,
      'location': this.location,
      'description': this.description,
      'status': this.status,
      'lastModified': this.lastModified.toIso8601String(),
    };
  }
}
