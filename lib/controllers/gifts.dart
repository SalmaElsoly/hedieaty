import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/shared/components/error_component.dart';

import '../models/event.dart';
import '../models/gift.dart';
import '../repositories/gift.dart';

class GiftsController {
  static GiftsController? _instance;

  static GiftsController get instance {
    _instance ??= GiftsController();
    return _instance!;
  }

  final GiftRepository _giftRepository = GiftRepository();
  final AuthService _authService = AuthService();

  Future<void> createGift(
      GiftModel gift, EventModel event, BuildContext context) async {
    try {
      await _giftRepository.createGift(gift, event);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<List<GiftModel>> getGifts(int eventId, BuildContext context) async {
    try {
      return await _giftRepository.getGifts(eventId);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
      return [];
    } catch (e) {
      showError('Error', e.toString(), context);
      return [];
    }
  }

  Future<void> updateGift(GiftModel gift, BuildContext context) async {
    try {
      await _giftRepository.updateGift(gift);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> deleteGift(
      GiftModel gift, EventModel event, BuildContext context) async {
    try {
      await _giftRepository.deleteGift(gift, event);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> pledgeGift(GiftModel gift, BuildContext context) async {
    try {
      await _giftRepository.pledgeGift(gift);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<List<GiftModel>> getGiftPledgedByMe(BuildContext context) async {
    try {
      final gifts =
          _giftRepository.getPledgedGifts(_authService.currentUser!.uid);
      return gifts;
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
      return [];
    } catch (e) {
      showError('Error', e.toString(), context);
      return [];
    }
  }

  Future<void> markGiftPurchased(GiftModel gift, BuildContext context) async {
    try {
      return await _giftRepository.completeGift(gift);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> cancelGift(GiftModel gift, BuildContext context) async {
    try {
      return await _giftRepository.unpledgeGift(gift);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }
}
