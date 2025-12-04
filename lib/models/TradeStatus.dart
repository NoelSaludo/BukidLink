enum TradeStatus {
  // Agreement Phase
  awaitingDeliveryMethod,       // Both need to agree on delivery
  deliveryMethodConflict,        // B requested change, A needs to respond
  awaitingMeetupDetails,         // Method agreed (meetup), A needs to set details
  meetupScheduled,               // Date set, B needs to confirm

  // Execution Phase
  readyToProceed,                // All details agreed, ready to start
  inProgress,                    // Trade is happening (packing/shipping/meetup)

  // Shipping Specific
  onePartyShipped,               // One shipped, 24hr timer for other
  bothShipping,                  // Both in transit

  // Completion
  awaitingMutualConfirmation,    // One confirmed, waiting for other
  completed,                     // Both confirmed

  // Final States
  cancelled,
  expired,                       // 24hr timer ran out
}

enum DeliveryMethod {
  shipping,
  meetup,
}

enum DeliveryMethodStatus {
  pending,        // Waiting for B to agree
  agreed,         // Both agreed
  changeRequested, // B requested change
}

enum ShippingStatus {
  notStarted,
  packing,
  packed,
  handedOver,
  shipping,
  delivered,
}

enum MeetupStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
}

// Extension for string conversion
extension TradeStatusExtension on TradeStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static TradeStatus fromString(String status) {
    return TradeStatus.values.firstWhere(
          (e) => e.toShortString() == status,
      orElse: () => TradeStatus.awaitingDeliveryMethod,
    );
  }
}

extension DeliveryMethodExtension on DeliveryMethod {
  String toShortString() {
    return toString().split('.').last;
  }

  static DeliveryMethod fromString(String method) {
    return DeliveryMethod.values.firstWhere(
          (e) => e.toShortString() == method,
      orElse: () => DeliveryMethod.shipping,
    );
  }
}

extension DeliveryMethodStatusExtension on DeliveryMethodStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static DeliveryMethodStatus fromString(String status) {
    return DeliveryMethodStatus.values.firstWhere(
          (e) => e.toShortString() == status,
      orElse: () => DeliveryMethodStatus.pending,
    );
  }
}

extension ShippingStatusExtension on ShippingStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static ShippingStatus fromString(String status) {
    return ShippingStatus.values.firstWhere(
          (e) => e.toShortString() == status,
      orElse: () => ShippingStatus.notStarted,
    );
  }
}

extension MeetupStatusExtension on MeetupStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static MeetupStatus fromString(String status) {
    return MeetupStatus.values.firstWhere(
          (e) => e.toShortString() == status,
      orElse: () => MeetupStatus.pending,
    );
  }
}