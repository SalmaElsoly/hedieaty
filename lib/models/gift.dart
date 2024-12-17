import 'package:cloud_firestore/cloud_firestore.dart';

enum GiftStatus { unpledged, purchased, pledged }

enum GiftCategory {
  electronics,
  clothing,
  home,
  toys,
  books,
  games,
  sports,
  automotive,
  jewelry,
  beauty,
  health,
  food,
  trips,
  other
}

class GiftModel {
  final int? id;
  int? eventId;
  String? firestoreId;
  final String name;
  final double price;
  final String description;
  final GiftCategory category;
  String? giftImageUrl;
  GiftStatus status;
  String? pledgedBy;
  final DateTime lastModified;
  final bool isDeleted;
  String? ownerId;
  String? deadline;

  GiftModel({
    this.id,
    this.eventId,
    this.firestoreId,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.giftImageUrl,
    this.status = GiftStatus.unpledged,
    this.pledgedBy,
    DateTime? lastModified,
    this.isDeleted = false,
    this.ownerId,
    this.deadline,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'firestoreId': firestoreId,
      'name': name,
      'price': price,
      'description': description,
      'category': category.toString().split('.').last,
      'giftImageUrl': giftImageUrl,
      'status': status.toString().split('.').last,
      'pledgedBy': pledgedBy,
      'lastModified': lastModified.toIso8601String(),
      'ownerId': ownerId,
      'deadline': deadline,
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
      category: GiftCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => GiftCategory.other,
      ),
      giftImageUrl: map['giftImageUrl'],
      status: GiftStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => GiftStatus.unpledged,
      ),
      pledgedBy: map['pledgedBy'],
      lastModified: DateTime.parse(map['lastModified']),
      isDeleted: map['isDeleted'] == 0 ? false : true,
      ownerId: map['ownerId'],
      deadline: map['deadline'],
    );
  }

  factory GiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GiftModel(
        firestoreId: doc.id,
        name: data['name'],
        price: data['price'],
        description: data['description'],
        category: GiftCategory.values.firstWhere(
          (e) => e.toString().split('.').last == data['category'],
        ),
        giftImageUrl: data['giftImageUrl'],
        status: GiftStatus.values.firstWhere(
          (e) => e.toString().split('.').last == data['status'],
          orElse: () => GiftStatus.unpledged,
        ),
        pledgedBy: data['pledgedBy'],
        lastModified: DateTime.parse(data['lastModified']),
        ownerId: data['ownerId'],
        deadline: data['deadline']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': this.name,
      'price': this.price,
      'description': this.description,
      'category': this.category.toString().split('.').last,
      'giftImageUrl': this.giftImageUrl,
      'status': this.status.toString().split('.').last,
      'pledgedBy': this.pledgedBy,
      'lastModified': this.lastModified.toIso8601String(),
      'ownerId': this.ownerId,
      'deadline': this.deadline,
    };
  }
}
