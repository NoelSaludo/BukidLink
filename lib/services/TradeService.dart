import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/TradeModels.dart';

class TradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TOGGLE TESTING HERE
  static const bool isTesting = false;

  // --- MOCK DATA ---
  final List<TradeListing> _mockListings = [
    TradeListing(
      id: '1',
      name: 'Sack of Rice (Sinandomeng)',
      quantity: '2 Sacks',
      description: 'Harvested last week. Good quality rice.',
      preferredTrades: ['Vegetables', 'Native Chicken'],
      image: 'assets/images/sample_rice.png',
      farmerId: 'test_user_uid',
      offersCount: 5,
      createdAt: DateTime.now(),
    ),
    TradeListing(
      id: '2',
      name: 'Fresh Tilapia',
      quantity: '5 Kilos',
      description: 'Fresh from the pond. Big sizes.',
      preferredTrades: ['Fruits', 'Fertilizer'],
      image: '',
      farmerId: 'other_user',
      offersCount: 1,
      createdAt: DateTime.now(),
    ),
  ];

  // --- HELPER: Get Current Farmer ID from 'farms' collection ---
  Future<String> _getCurrentFarmerId() async {
    User? user = _auth.currentUser;
    if (user == null)
      return 'anon_user'; // anon user is use for testing purposes
    // remove anon user if magcause nalang ng bug

    try {
      // Check 'farms' collection where the 'uid' matches current logged in user
      QuerySnapshot snapshot = await _db
          .collection('farms')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Return the specific 'farmer_id' field from the database
        return snapshot.docs.first.get('farmer_id') ?? user.uid;
      }
    } catch (e) {
      print("Error fetching farmer_id: $e");
    }
    // Fallback to Auth UID if no farm profile is found
    return user.uid;
  }

  // --- 1. READ LISTINGS (Public Feed - Excludes Me) ---
  Stream<List<TradeListing>> getTradeListings(String searchText) {
    if (isTesting) {
      // Return a single-subscription stream that immediately emits mock data
      final controller = StreamController<List<TradeListing>>();
      final filtered = _mockListings
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchText.toLowerCase()),
          )
          .toList();
      // Delay to mimic async behavior
      Future.microtask(() {
        controller.add(filtered);
        controller.close();
      });
      return controller.stream;
    }

    // Use a broadcast controller so multiple listeners (hot reload, tab switches)
    // won't cause 'Stream has already been listened to' errors.
    final controller = StreamController<List<TradeListing>>.broadcast();
    StreamSubscription? sub;

    controller.onListen = () async {
      final currentFarmerId = await _getCurrentFarmerId();

      sub = _db
          .collection('trade_listings')
          .orderBy('created_at', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              final results = snapshot.docs
                  .map((doc) => TradeListing.fromMap(doc.data(), doc.id))
                  .where((item) {
                    final matchesSearch = item.name.toLowerCase().contains(
                      searchText.toLowerCase(),
                    );
                    final isNotMe = item.farmerId != currentFarmerId;
                    return matchesSearch && isNotMe;
                  })
                  .toList();

              controller.add(results);
            },
            onError: (err, stack) {
              controller.addError(err, stack);
            },
          );
    };

    controller.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };

    return controller.stream;
  }

  // --- 2. READ MY TRADES (Private Feed - Only Me) ---
  Stream<List<TradeListing>> getMyTrades(String searchText) {
    if (isTesting) {
      final controller = StreamController<List<TradeListing>>();
      Future.microtask(() {
        controller.add([]);
        controller.close();
      });
      return controller.stream;
    }

    final controller = StreamController<List<TradeListing>>.broadcast();
    StreamSubscription? sub;

    controller.onListen = () async {
      final currentFarmerId = await _getCurrentFarmerId();

      sub = _db
          .collection('trade_listings')
          .where('farmer_id', isEqualTo: currentFarmerId)
          .snapshots()
          .listen(
            (snapshot) {
              final results = snapshot.docs
                  .map((doc) => TradeListing.fromMap(doc.data(), doc.id))
                  .where(
                    (item) => item.name.toLowerCase().contains(
                      searchText.toLowerCase(),
                    ),
                  )
                  .toList();

              controller.add(results);
            },
            onError: (err, stack) {
              controller.addError(err, stack);
            },
          );
    };

    controller.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };

    return controller.stream;
  }

  // --- NEW: FETCH MY LISTINGS (Future) ---
  Future<List<TradeListing>> fetchMyListingsFuture() async {
    if (isTesting) return [];

    try {
      final currentFarmerId = await _getCurrentFarmerId();
      final snapshot = await _db
          .collection('trade_listings')
          .where('farmer_id', isEqualTo: currentFarmerId)
          .get();

      return snapshot.docs
          .map((doc) => TradeListing.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching my listings: $e");
      return [];
    }
  }

  // --- NEW: FETCH OFFERS FOR A LISTING (Future) ---
  Future<List<TradeOfferRequest>> fetchOffersForListingFuture(
    String listingId,
  ) async {
    if (isTesting) return [];

    try {
      final snapshot = await _db
          .collection('trade_offers')
          .where('listing_id', isEqualTo: listingId)
          .get();

      return snapshot.docs
          .map((doc) => TradeOfferRequest.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching offers for listing $listingId: $e");
      return [];
    }
  }

  // --- NEW: DECLINE OFFER (Delete Offer & Decrement Count) ---
  Future<void> declineOffer(String offerId, String listingId) async {
    if (isTesting) return;

    WriteBatch batch = _db.batch();

    // 1. Delete the offer
    DocumentReference offerRef = _db.collection('trade_offers').doc(offerId);
    batch.delete(offerRef);

    // 2. Decrement offers_count on the listing
    DocumentReference listingRef = _db
        .collection('trade_listings')
        .doc(listingId);
    batch.update(listingRef, {'offers_count': FieldValue.increment(-1)});

    await batch.commit();
  }

  // --- NEW: ACCEPT OFFER (Update Status) ---
  Future<void> acceptOffer(String offerId) async {
    if (isTesting) return;

    // For now, just update the status to 'accepted'.
    // Logic for inventory deduction or messaging can be added here.
    await _db.collection('trade_offers').doc(offerId).update({
      'status': 'accepted',
    });
  }

  // --- 3. CREATE LISTING (Uses Farmer ID) ---
  Future<void> createListing(TradeListing listing) async {
    if (isTesting) {
      await Future.delayed(Duration(seconds: 1));
      _mockListings.add(listing);
      return;
    }

    // Get the correct Farmer ID from the database
    String currentFarmerId = await _getCurrentFarmerId();

    // Prepare data
    var data = listing.toMap();
    data['farmer_id'] = currentFarmerId; // <--- Saves as 'farmer_id'

    await _db.collection('trade_listings').add(data);
  }

  // --- 4. UPDATE LISTING (New) ---
  Future<void> updateListing(TradeListing listing) async {
    if (isTesting) return;

    // Create specific update map to preserve created_at and offers_count
    Map<String, dynamic> data = {
      'name': listing.name,
      'quantity': listing.quantity,
      'description': listing.description,
      'preferred_trades': listing.preferredTrades,
      'image': listing.image,
      'farmer_id': listing.farmerId,
    };

    await _db.collection('trade_listings').doc(listing.id).update(data);
  }

  // --- 5. DELETE LISTING (New) ---
  Future<void> deleteListing(String listingId) async {
    if (isTesting) {
      _mockListings.removeWhere((l) => l.id == listingId);
      return;
    }

    // 1. Delete the listing itself
    await _db.collection('trade_listings').doc(listingId).delete();

    // 2. Delete all offers associated with this listing (Clean up)
    var offers = await _db
        .collection('trade_offers')
        .where('listing_id', isEqualTo: listingId)
        .get();

    for (var doc in offers.docs) {
      await doc.reference.delete();
    }
  }

  // --- 6. SUBMIT OFFER (Increments Count) ---
  Future<void> submitOffer(TradeOfferRequest offer) async {
    if (isTesting) {
      await Future.delayed(Duration(seconds: 1));
      return;
    }

    // Use a Batch Write to ensure both actions succeed together
    WriteBatch batch = _db.batch();

    // A. Add the Offer to 'trade_offers' collection
    DocumentReference offerRef = _db.collection('trade_offers').doc();
    batch.set(offerRef, offer.toMap());

    // B. Increment the 'offers_count' on the specific listing
    DocumentReference listingRef = _db
        .collection('trade_listings')
        .doc(offer.listingId);

    batch.update(listingRef, {
      'offers_count': FieldValue.increment(1), // <--- Automatically adds 1
    });

    await batch.commit();
  }

  // --- 7. GET OFFERS FOR LISTING ---
  Stream<List<TradeOfferRequest>> getOffersForListing(String listingId) {
    return _db
        .collection('trade_offers')
        .where('listing_id', isEqualTo: listingId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TradeOfferRequest.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
