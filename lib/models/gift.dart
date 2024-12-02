import 'package:cloud_firestore/cloud_firestore.dart';

class GiftModel {
  final int? id;
  final int eventId;
  final String? firestoreId;
  final String name;
  final double price;
  final String description;
  final String category;
  final String? giftImageUrl;
  final String status;
  final int? pledgedBy;
  final DateTime lastModified;

  GiftModel({
    this.id,
    required this.eventId,
    this.firestoreId,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.giftImageUrl,
    this.status = 'unpledged',
    this.pledgedBy,
    DateTime? lastModified,
  })  : lastModified = lastModified ?? DateTime.now(),
        assert(status == 'unpledged' ||
            status == 'purchased' ||
            status == 'pledged');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'firestoreId': firestoreId,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'giftImageUrl': giftImageUrl,
      'status': status,
      'pledgedBy': pledgedBy,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory GiftModel.fromMap(Map<String, dynamic> map) {
    return GiftModel(
      id: map['id'],
      eventId: map['eventId'],
      firestoreId: map['firestoreId'],
      name: map['name'],
      price: map['price'],
      description: map['description'],
      category: map['category'],
      giftImageUrl: map['giftImageUrl'],
      status: map['status'],
      pledgedBy: map['pledgedBy'],
      lastModified: DateTime.parse(map['lastModified']),
    );
  }

  factory GiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GiftModel(
      id: data['id'],
      eventId: data['eventId'],
      firestoreId: doc.id,
      name: data['name'],
      price: data['price'],
      description: data['description'],
      category: data['category'],
      giftImageUrl: data['giftImageUrl'],
      status: data['status'],
      pledgedBy: data['pledgedBy'],
      lastModified: DateTime.parse(data['lastModified']),
    );
  }
}
