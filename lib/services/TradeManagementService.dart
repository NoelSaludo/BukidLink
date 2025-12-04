// trade_management_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bukidlink/models/Trade.dart';
import 'package:bukidlink/models/TradeStatus.dart';

class TradeManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tradesCollection = 'trades';
  final String _listingsCollection = 'trade_listings';
  final String _offersCollection = 'trade_offer_requests';

  // TRADE CREATION

  // Create new trade from accepted TradeOfferRequest
  Future<String> createTradeFromOffer({
    required String offerRequestId,
    required String listingId,
    required String farmerAId,
    required String farmerAName,
    required String farmerAAddress,
    required String farmerBId,
    required String farmerBName,
    required String farmerBAddress,
    required TradeItem farmerAItem,
    required TradeItem farmerBItem,
    required DeliveryMethod initialDeliveryMethod,
  }) async {
    final now = DateTime.now();

    final trade = Trade(
      id: '',
      offerRequestId: offerRequestId,
      listingId: listingId,
      farmerAId: farmerAId,
      farmerAName: farmerAName,
      farmerAAddress: farmerAAddress,
      farmerBId: farmerBId,
      farmerBName: farmerBName,
      farmerBAddress: farmerBAddress,
      farmerAItem: farmerAItem,
      farmerBItem: farmerBItem,
      deliveryMethod: initialDeliveryMethod,
      deliveryMethodStatus: DeliveryMethodStatus.pending,
      status: TradeStatus.awaitingDeliveryMethod,
      createdAt: now,
      updatedAt: now,
    );

    final docRef = await _firestore.collection(_tradesCollection).add(trade.toMap());

    // Try to update the original offer request status
    try {
      final offerDoc = await _firestore.collection(_offersCollection).doc(offerRequestId).get();
      if (offerDoc.exists) {
        await _firestore.collection(_offersCollection).doc(offerRequestId).update({
          'status': 'accepted',
          'trade_id': docRef.id,
        });
      }
    } catch (e) {
      // Log but don't fail if offer update fails
      print('Warning: Could not update offer request: $e');
    }

    return docRef.id;
  }

  // DELIVERY METHOD MANAGEMENT

  // Farmer B agrees to the delivery method proposed by Farmer A
  Future<void> agreeToDeliveryMethod(String tradeId) async {
    final trade = await _getTrade(tradeId);

    if (trade.deliveryMethodStatus != DeliveryMethodStatus.pending &&
        trade.deliveryMethodStatus != DeliveryMethodStatus.changeRequested) {
      throw Exception('Delivery method already agreed');
    }

    TradeStatus newStatus;
    if (trade.deliveryMethod == DeliveryMethod.meetup) {
      newStatus = TradeStatus.awaitingMeetupDetails;
    } else {
      newStatus = TradeStatus.readyToProceed;
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      'delivery_method_status': DeliveryMethodStatus.agreed.toShortString(),
      'status': newStatus.toShortString(),
      'delivery_change_requested_by': null,
      'delivery_change_reason': null,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Farmer B requests a change to the delivery method
  Future<void> requestDeliveryChange(
      String tradeId,
      String reason,
      DeliveryMethod newMethod,
      ) async {
    final trade = await _getTrade(tradeId);

    if (trade.deliveryMethodStatus == DeliveryMethodStatus.agreed) {
      throw Exception('Delivery method already agreed');
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      'delivery_method_status': DeliveryMethodStatus.changeRequested.toShortString(),
      'status': TradeStatus.deliveryMethodConflict.toShortString(),
      'delivery_change_requested_by': trade.farmerBId,
      'delivery_change_reason': reason,
      'delivery_method': newMethod.toShortString(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Farmer A responds to delivery method change request
  Future<void> respondToDeliveryChange(String tradeId, bool approve) async {
    final trade = await _getTrade(tradeId);

    if (trade.deliveryMethodStatus != DeliveryMethodStatus.changeRequested) {
      throw Exception('No delivery change request pending');
    }

    if (approve) {
      TradeStatus newStatus;
      if (trade.deliveryMethod == DeliveryMethod.meetup) {
        newStatus = TradeStatus.awaitingMeetupDetails;
      } else {
        newStatus = TradeStatus.readyToProceed;
      }

      await _firestore.collection(_tradesCollection).doc(tradeId).update({
        'delivery_method_status': DeliveryMethodStatus.agreed.toShortString(),
        'status': newStatus.toShortString(),
        'delivery_change_requested_by': null,
        'delivery_change_reason': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Reject - revert to original method and pending status
      await _firestore.collection(_tradesCollection).doc(tradeId).update({
        'delivery_method_status': DeliveryMethodStatus.pending.toShortString(),
        'status': TradeStatus.awaitingDeliveryMethod.toShortString(),
        'delivery_change_requested_by': null,
        'delivery_change_reason': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // MEETUP MANAGEMENT

  // Farmer A sets meetup details
  Future<void> setMeetupDetails(
      String tradeId,
      DateTime date,
      String time,
      String location,
      ) async {
    final trade = await _getTrade(tradeId);

    if (trade.deliveryMethod != DeliveryMethod.meetup) {
      throw Exception('Trade is not using meetup delivery method');
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      'meetup_date': Timestamp.fromDate(date),
      'meetup_time': time,
      'meetup_location': location,
      'meetup_status': MeetupStatus.pending.toShortString(),
      'status': TradeStatus.meetupScheduled.toShortString(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Farmer B confirms meetup details
  Future<void> confirmMeetupDetails(String tradeId) async {
    final trade = await _getTrade(tradeId);

    if (trade.meetupStatus != MeetupStatus.pending) {
      throw Exception('Meetup details not pending confirmation');
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      'meetup_status': MeetupStatus.confirmed.toShortString(),
      'status': TradeStatus.readyToProceed.toShortString(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Farmer checks in to meetup location
  Future<void> checkInToMeetup(String tradeId, String farmerId) async {
    final trade = await _getTrade(tradeId);

    if (trade.meetupStatus != MeetupStatus.confirmed &&
        trade.meetupStatus != MeetupStatus.checkedIn) {
      throw Exception('Meetup not confirmed yet');
    }

    final isFarmerA = farmerId == trade.farmerAId;
    final checkInField = isFarmerA ? 'farmer_a_checked_in' : 'farmer_b_checked_in';
    final otherCheckedIn = isFarmerA ? trade.farmerBCheckedIn : trade.farmerACheckedIn;

    Map<String, dynamic> updates = {
      checkInField: true,
      'updated_at': FieldValue.serverTimestamp(),
    };

    // If both checked in, move to in progress
    if (otherCheckedIn == true) {
      updates['meetup_status'] = MeetupStatus.checkedIn.toShortString();
      updates['status'] = TradeStatus.inProgress.toShortString();
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update(updates);
  }

  // SHIPPING MANAGEMENT

  // Update shipping status for a farmer
  Future<void> updateShippingStatus(
      String tradeId,
      String farmerId,
      ShippingStatus status, {
        String? trackingNumber,
      }) async {
    final trade = await _getTrade(tradeId);

    if (trade.deliveryMethod != DeliveryMethod.shipping) {
      throw Exception('Trade is not using shipping delivery method');
    }

    final isFarmerA = farmerId == trade.farmerAId;
    final fieldPrefix = isFarmerA ? 'farmer_a' : 'farmer_b';

    Map<String, dynamic> updates = {
      '${fieldPrefix}_shipping_status': status.toShortString(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (trackingNumber != null) {
      updates['${fieldPrefix}_tracking_number'] = trackingNumber;
    }

    // If handed over or shipping, set shipped date and deadline
    if (status == ShippingStatus.handedOver || status == ShippingStatus.shipping) {
      final now = DateTime.now();
      updates['${fieldPrefix}_shipped_at'] = Timestamp.fromDate(now);

      // Check other party's status
      final otherShippingStatus = isFarmerA
          ? trade.farmerBShippingStatus
          : trade.farmerAShippingStatus;

      if (otherShippingStatus == ShippingStatus.notStarted ||
          otherShippingStatus == ShippingStatus.packing ||
          otherShippingStatus == ShippingStatus.packed) {
        // Set 24-hour deadline for other party
        updates['shipping_deadline'] = Timestamp.fromDate(now.add(Duration(hours: 24)));
        updates['status'] = TradeStatus.onePartyShipped.toShortString();
      } else {
        // Both parties have shipped
        updates['status'] = TradeStatus.bothShipping.toShortString();
        updates['shipping_deadline'] = null; // Clear deadline
      }
    } else if (status == ShippingStatus.packing || status == ShippingStatus.packed) {
      updates['status'] = TradeStatus.inProgress.toShortString();
    } else if (status == ShippingStatus.delivered) {
      // Check if both delivered
      final otherShippingStatus = isFarmerA
          ? trade.farmerBShippingStatus
          : trade.farmerAShippingStatus;

      if (otherShippingStatus == ShippingStatus.delivered) {
        updates['status'] = TradeStatus.awaitingMutualConfirmation.toShortString();
      }
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update(updates);
  }

  // Request extension for shipping deadline
  Future<void> requestExtension(String tradeId, String farmerId) async {
    final trade = await _getTrade(tradeId);

    if (trade.shippingDeadline == null) {
      throw Exception('No shipping deadline to extend');
    }

    if (DateTime.now().isAfter(trade.shippingDeadline!)) {
      throw Exception('Shipping deadline has already passed');
    }

    final isFarmerA = farmerId == trade.farmerAId;
    final fieldName = isFarmerA
        ? 'farmer_a_requested_extension'
        : 'farmer_b_requested_extension';

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      fieldName: true,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Respond to extension request
  Future<void> respondToExtension(
      String tradeId,
      String farmerId,
      bool approve,
      ) async {
    final trade = await _getTrade(tradeId);

    final isFarmerA = farmerId == trade.farmerAId;
    final otherRequestedExtension = isFarmerA
        ? trade.farmerBRequestedExtension
        : trade.farmerARequestedExtension;

    if (!otherRequestedExtension) {
      throw Exception('No extension request to respond to');
    }

    Map<String, dynamic> updates = {
      'farmer_a_requested_extension': false,
      'farmer_b_requested_extension': false,
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (approve && trade.shippingDeadline != null) {
      // Extend deadline by 24 hours
      final newDeadline = trade.shippingDeadline!.add(Duration(hours: 24));
      updates['shipping_deadline'] = Timestamp.fromDate(newDeadline);
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update(updates);
  }

  // COMPLETION

  // Farmer confirms trade completion
  Future<void> confirmCompletion(String tradeId, String farmerId) async {
    final trade = await _getTrade(tradeId);

    if (trade.status == TradeStatus.completed ||
        trade.status == TradeStatus.cancelled) {
      throw Exception('Trade already finalized');
    }

    final isFarmerA = farmerId == trade.farmerAId;
    final fieldName = isFarmerA
        ? 'farmer_a_confirmed_complete'
        : 'farmer_b_confirmed_complete';

    final otherConfirmed = isFarmerA
        ? trade.farmerBConfirmedComplete
        : trade.farmerAConfirmedComplete;

    Map<String, dynamic> updates = {
      fieldName: true,
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (otherConfirmed) {
      // Both confirmed - complete the trade
      updates['status'] = TradeStatus.completed.toShortString();
      updates['completed_at'] = FieldValue.serverTimestamp();

      if (trade.deliveryMethod == DeliveryMethod.meetup) {
        updates['meetup_status'] = MeetupStatus.completed.toShortString();
      }
    } else {
      // Only one confirmed - wait for other
      updates['status'] = TradeStatus.awaitingMutualConfirmation.toShortString();
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update(updates);
  }

  //  CANCELLATION

  // Cancel a trade
  Future<void> cancelTrade(
      String tradeId,
      String farmerId,
      String reason,
      ) async {
    final trade = await _getTrade(tradeId);

    if (trade.status == TradeStatus.completed) {
      throw Exception('Cannot cancel completed trade');
    }

    await _firestore.collection(_tradesCollection).doc(tradeId).update({
      'status': TradeStatus.cancelled.toShortString(),
      'cancelled_by': farmerId,
      'cancellation_reason': reason,
      'cancelled_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Update offer request status
    if (trade.offerRequestId != null) {
      await _firestore.collection(_offersCollection).doc(trade.offerRequestId).update({
        'status': 'cancelled',
      });
    }
  }

  //  QUERY METHODS

  // Get a single trade by ID
  Future<Trade> _getTrade(String tradeId) async {
    final doc = await _firestore.collection(_tradesCollection).doc(tradeId).get();

    if (!doc.exists) {
      throw Exception('Trade not found');
    }

    return Trade.fromFirestore(doc);
  }

  // Get trade by ID (public method)
  Future<Trade> getTrade(String tradeId) async {
    return _getTrade(tradeId);
  }

  // Stream a single trade
  Stream<Trade> streamTrade(String tradeId) {
    return _firestore
        .collection(_tradesCollection)
        .doc(tradeId)
        .snapshots()
        .map((doc) => Trade.fromFirestore(doc))
        .asBroadcastStream();
  }

  // Get all trades for a farmer (combining both farmer A and B queries)
  Future<List<Trade>> getTradesForFarmer(String farmerId) async {
    // Query where user is Farmer A
    final querySnapshot1 = await _firestore
        .collection(_tradesCollection)
        .where('farmer_a_id', isEqualTo: farmerId)
        .orderBy('created_at', descending: true)
        .get();

    // Query where user is Farmer B
    final querySnapshot2 = await _firestore
        .collection(_tradesCollection)
        .where('farmer_b_id', isEqualTo: farmerId)
        .orderBy('created_at', descending: true)
        .get();

    // Combine and deduplicate
    final seen = <String>{};
    final trades = <Trade>[];

    for (var doc in [...querySnapshot1.docs, ...querySnapshot2.docs]) {
      if (!seen.contains(doc.id)) {
        trades.add(Trade.fromFirestore(doc));
        seen.add(doc.id);
      }
    }

    // Sort by creation date
    trades.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return trades;
  }

  // Stream all trades for a farmer (better approach - single stream)
  Stream<List<Trade>> streamAllTradesForFarmer(String farmerId) {
    return StreamZip([
      _firestore
          .collection(_tradesCollection)
          .where('farmer_a_id', isEqualTo: farmerId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Trade.fromFirestore(doc)).toList()),
      _firestore
          .collection(_tradesCollection)
          .where('farmer_b_id', isEqualTo: farmerId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Trade.fromFirestore(doc)).toList()),
    ]).map((combinedLists) {
      final seen = <String>{};
      final combined = <Trade>[];

      for (var tradeList in combinedLists) {
        for (var trade in tradeList) {
          if (!seen.contains(trade.id)) {
            combined.add(trade);
            seen.add(trade.id);
          }
        }
      }

      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }).asBroadcastStream();
  }

  // Get active trades for a farmer
  Future<List<Trade>> getActiveTradesForFarmer(String farmerId) async {
    final allTrades = await getTradesForFarmer(farmerId);
    return allTrades.where((trade) =>
    trade.status != TradeStatus.completed &&
        trade.status != TradeStatus.cancelled &&
        trade.status != TradeStatus.expired
    ).toList();
  }

  // Get completed trades for a farmer
  Future<List<Trade>> getCompletedTradesForFarmer(String farmerId) async {
    final allTrades = await getTradesForFarmer(farmerId);
    return allTrades.where((trade) =>
    trade.status == TradeStatus.completed
    ).toList();
  }

  // Check and expire trades past shipping deadline
  Future<void> checkAndExpireTrades() async {
    final now = DateTime.now();
    final querySnapshot = await _firestore
        .collection(_tradesCollection)
        .where('status', isEqualTo: TradeStatus.onePartyShipped.toShortString())
        .get();

    for (var doc in querySnapshot.docs) {
      final trade = Trade.fromFirestore(doc);
      if (trade.shippingDeadline != null &&
          now.isAfter(trade.shippingDeadline!)) {
        await _firestore.collection(_tradesCollection).doc(trade.id).update({
          'status': TradeStatus.expired.toShortString(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Get trade statistics for a farmer
  Future<Map<String, int>> getTradeStats(String farmerId) async {
    final allTrades = await getTradesForFarmer(farmerId);

    return {
      'total': allTrades.length,
      'active': allTrades.where((t) =>
      t.status != TradeStatus.completed &&
          t.status != TradeStatus.cancelled &&
          t.status != TradeStatus.expired
      ).length,
      'completed': allTrades.where((t) => t.status == TradeStatus.completed).length,
      'cancelled': allTrades.where((t) => t.status == TradeStatus.cancelled).length,
      'expired': allTrades.where((t) => t.status == TradeStatus.expired).length,
    };
  }
}

class StreamZip<T> extends Stream<List<T>> {
  final List<Stream<T>> _streams;

  StreamZip(this._streams);

  @override
  StreamSubscription<List<T>> listen(
      void Function(List<T> event)? onData, {
        Function? onError,
        void Function()? onDone,
        bool? cancelOnError,
      }) {
    final values = List<T?>.filled(_streams.length, null);
    final subscriptions = <StreamSubscription<T>>[];
    final controller = StreamController<List<T>>();
    int completedCount = 0;

    void checkAndEmit() {
      if (values.every((v) => v != null)) {
        if (!controller.isClosed) {
          controller.add(values.cast<T>());
        }
      }
    }

    for (var i = 0; i < _streams.length; i++) {
      final index = i;
      subscriptions.add(
        _streams[i].listen(
              (data) {
            values[index] = data;
            checkAndEmit();
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
          onDone: () {
            completedCount++;
            if (completedCount == _streams.length) {
              if (!controller.isClosed) {
                controller.close();
              }
            }
          },
          cancelOnError: cancelOnError ?? false,
        ),
      );
    }

    controller.onCancel = () {
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
    };

    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}