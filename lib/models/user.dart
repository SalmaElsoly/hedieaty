import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final int? id;
  final String? firestoreId;
  final String email;
  final String username;
  final String? profileImage;
  int eventsCount;
  final DateTime lastModified;
  // array of doc ref to events
  List<DocumentReference> events=[];
  List<DocumentReference> friends=[];

  UserModel({
    this.id,
    this.firestoreId,
    required this.email,
    required this.username,
    this.profileImage,
    this.eventsCount = 0,
    DateTime? lastModified,
    List<DocumentReference>? events,
    List<DocumentReference>? friends,
  }) : lastModified = lastModified ?? DateTime.now(),
       events = events ?? const [],
  friends = friends ?? const [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'email': email,
      'username': username,
      'profileImage': profileImage,
      'eventsCount': eventsCount,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      firestoreId: map['firestoreId'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      profileImage: map['profileImage'] as String?,
      eventsCount: map['eventsCount'] as int? ?? 0,
      lastModified: DateTime.parse(map['lastModified'] as String),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      firestoreId: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      profileImage: data['photoUrl'],
      eventsCount: data['eventsCount'] ?? 0,
      lastModified: (data['lastModified'] as Timestamp).toDate(),
        events: data['events'] != null && data['events'] is List
            ? (data['events'] as List<dynamic>).map((path) {
          if (path != null && path is String) {
            return FirebaseFirestore.instance.doc(path);
          } else {
            return null;
          }
        }).whereType<DocumentReference>().toList()
            : [],
      friends: data['friends'] != null && data['friends'] is List
          ? (data['friends'] as List<dynamic>).map((path) {
        if (path != null && path is String) {
          return FirebaseFirestore.instance.doc(path);
        } else {
          return null;
        }
      }).whereType<DocumentReference>().toList()
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'photoUrl': profileImage,
      'eventsCount': eventsCount,
      'lastModified': Timestamp.fromDate(lastModified),
      'events': events.map((e) => e.path).toList(),
      'friends': friends.map((e) => e.path).toList()
    };
  }
}
