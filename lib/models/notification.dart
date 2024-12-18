
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String message;
  final DateTime timestamp;
  final String userId;

  NotificationModel({
    required this.message,
    required this.timestamp,
    required this.userId,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data) {
    return NotificationModel(
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
    };
  }}
