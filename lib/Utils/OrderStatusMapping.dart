import 'package:flutter/material.dart';
import 'package:bukidlink/models/FarmerOrderSubstatus.dart';

/// Mapping farmer stage to a display string
String getFarmerStageText(FarmerSubStatus stage) {
  switch (stage) {
    case FarmerSubStatus.pending:
      return 'Pending';
    case FarmerSubStatus.toPack:
      return 'To Pack';
    case FarmerSubStatus.toHandover:
      return 'To Handover';
    case FarmerSubStatus.shipping:
      return 'Shipping';
    case FarmerSubStatus.completed:
      return 'Completed';
    default:
      return '';
  }
}

/// Color coding for stages
Color getFarmerStageColor(FarmerSubStatus stage) {
  switch (stage) {
    case FarmerSubStatus.pending:
      return Colors.orange;
    case FarmerSubStatus.toPack:
      return Colors.blue;
    case FarmerSubStatus.toHandover:
      return Colors.indigo;
    case FarmerSubStatus.shipping:
      return Colors.purple;
    case FarmerSubStatus.completed:
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// Actions the farmer can perform per stage
List<String> getFarmerStageActions(FarmerSubStatus stage) {
  switch (stage) {
    case FarmerSubStatus.pending:
      return ['Accept', 'Reject'];
    case FarmerSubStatus.toPack:
      return ['Mark Ready for Handover', 'Print Receipt'];
    case FarmerSubStatus.toHandover:
      return ['Mark as Shipped'];
    case FarmerSubStatus.shipping:
      return ['Contact Buyer'];
    case FarmerSubStatus.completed:
      return ['View Receipt'];
    default:
      return [];
  }
}

/// Farmer stage to equivalent customer order status
String mapToCustomerStatus(FarmerSubStatus stage) {
  switch (stage) {
    case FarmerSubStatus.pending:
      return 'To Pay';
    case FarmerSubStatus.toPack:
      return 'To Ship (Preparing)';
    case FarmerSubStatus.toHandover:
      return 'To Ship (Handing over)';
    case FarmerSubStatus.shipping:
      return 'To Receive';
    case FarmerSubStatus.completed:
      return 'Completed';
    default:
      return '';
  }
}
