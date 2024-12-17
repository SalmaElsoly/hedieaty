import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/services/storage.dart';

import '../models/gift.dart';
import '../shared/database/firestore.dart';
import '../shared/database/local_db.dart';
import 'sync_helper.dart';

class GiftRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalDB _localDB = LocalDB();
  late SyncHelper _syncHelper = SyncHelper(_firestoreService, _localDB);
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  Future<void> createGift(GiftModel gift, EventModel event) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot create gift remotely.");
      }
      gift.ownerId = _authService.currentUser!.uid;
      gift.deadline = event.date;

      final firestoreId = await _firestoreService.createGift(gift);
      if (gift.firestoreId == null) {
        gift.firestoreId = firestoreId;
      }

      await _firestoreService.addGiftToEvent(event.firestoreId!, gift);
      final giftId = await _localDB.insertGift(gift);
      final imageUrl = await _storageService.uploadImageToGifts(
          gift.firestoreId!, gift.giftImageUrl!);
      final insertedgift = await _localDB.getGiftById(giftId);
      insertedgift.giftImageUrl = imageUrl;
      gift.giftImageUrl = imageUrl;

      await _localDB.updateGift(insertedgift);
      await _firestoreService.updateGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GiftModel>> getGifts(int eventId) async {
    try {
      final localGifts = await _localDB.getGiftsByEventId(eventId);

      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      if (isConnected) {
        final event = await _localDB.getEvent(eventId);
        final remoteGifts =
            await _firestoreService.getGiftsByEventId(event.firestoreId!);
        await _syncHelper.syncGifts(eventId, remoteGifts);
        final updatedGifts = await _localDB.getGiftsByEventId(eventId);
        return updatedGifts;
      } else {
        return localGifts;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGift(GiftModel gift) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot update gift remotely.");
      }
      final downloadUrl = await _storageService.uploadImageToGifts(
          gift.firestoreId!, gift.giftImageUrl!);
      gift.giftImageUrl = downloadUrl;
      await _firestoreService.updateGift(gift);
      await _localDB.updateGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGift(GiftModel gift, EventModel event) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot delete gift remotely.");
      }
      await _firestoreService.removeGiftFromEvent(
          event.firestoreId!, gift.firestoreId!);
      await _firestoreService.deleteGift(gift.firestoreId!);
      await _localDB.deleteGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pledgeGift(GiftModel gift) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot pledge gift remotely.");
      }
      gift.status = GiftStatus.pledged;
      gift.pledgedBy = _authService.currentUser!.uid;
      await _firestoreService.updateGift(gift);
      await _localDB.updateGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unpledgeGift(GiftModel gift) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception(
            "No internet connection. Cannot unpledge gift remotely.");
      }
      gift.status = GiftStatus.unpledged;
      gift.pledgedBy = '';
      await _firestoreService.updateGift(gift);
      await _localDB.updateGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeGift(GiftModel gift) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception(
            "No internet connection. Cannot complete gift remotely.");
      }
      gift.status = GiftStatus.purchased;
      await _firestoreService.updateGift(gift);
      await _localDB.updateGift(gift);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GiftModel>> getPledgedGifts(String userId) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        return await _localDB.getPledgedGifts(userId);
      }
      final gifts = await _firestoreService.getPledgedGifts(userId);
      return gifts;
    } catch (e) {
      rethrow;
    }
  }
}
