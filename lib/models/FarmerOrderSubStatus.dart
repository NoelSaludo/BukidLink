enum FarmerSubStatus {
  pending,      // Awaiting farmer approval
  toPack,       // Farmer is preparing/packing the order
  toHandover,   // Ready to handover to courier
  shipping,     // Courier delivering
  completed,    // Completed order
}