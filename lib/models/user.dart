import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final int? id;
  final String? firestoreId;
  final String mobileNumber;
  final String username;
  final String? profileImage;
  final DateTime lastModified;
  User({
    this.id,
    this.firestoreId,
    required this.mobileNumber,
    required this.username,
    this.profileImage,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'mobileNumber': mobileNumber,
      'username': username,
      'profileImage': profileImage,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      firestoreId: map['firestoreId'] as String,
      mobileNumber: map['mobileNumber'] as String,
      username: map['username'] as String,
      profileImage: map['profileImage'] as String?,
      lastModified: DateTime.parse(map['lastModified'] as String),
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      firestoreId: doc.id,
      mobileNumber: data['mobile'] ?? '',
      username: data['username'] ?? '',
      profileImage: data['photoUrl'],
      lastModified: (data['lastModified'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mobile': mobileNumber,
      'username': username,
      'photoUrl': profileImage,
      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
}