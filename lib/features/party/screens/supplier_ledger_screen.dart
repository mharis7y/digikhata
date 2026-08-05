import 'package:flutter/material.dart';
import '../models/party_model.dart';
import 'customer_ledger_screen.dart';

/// Supplier Ledger Screen — reuses the same UI as CustomerLedgerScreen
/// since the workflow is identical per agents.md.
/// Suppliers use: Purchase (You Gave = goods received) / Payment (You Got = payment made)
class SupplierLedgerScreen extends StatelessWidget {
  final PartyModel party;

  const SupplierLedgerScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    // Reuse CustomerLedgerScreen — the party.type will adapt labels
    return CustomerLedgerScreen(party: party);
  }
}
