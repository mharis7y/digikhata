import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/party_model.dart';
import '../models/ledger_entry_model.dart';
import '../providers/party_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/pdf_export_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Customer Ledger Screen per agents.md:
/// - Header: name, "Customer" tag, call icon, overflow menu
/// - Privacy indicator ("Only you can see these entries")
/// - Empty state with "Add first entry" prompt
/// - Two entry actions: You Gave (debit, red) / You Got (credit, green)
/// - Each entry shows amount, balance, date/time, optional note/items
class CustomerLedgerScreen extends StatefulWidget {
  final PartyModel party;

  const CustomerLedgerScreen({super.key, required this.party});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  late PartyModel _party;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _party = widget.party;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartyProvider>().loadLedgerEntries(_party.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LedgerEntryModel> _filtered(List<LedgerEntryModel> all) {
    if (_searchQuery.isEmpty) return all;
    return all
        .where((e) =>
            (e.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          // ─── Ledger App Bar ────────────────────────────────────────────
          _LedgerAppBar(party: _party),

          // ─── Balance Summary ────────────────────────────────────────────
          _LedgerBalanceCard(party: _party),

          // ─── Quick Action Bar (Report/Reminder/SMS) ─────────────────────
          _QuickActionBar(party: _party),

          // ─── Search ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                    fontFamily: 'Poppins', color: Color(0xFF9CA3AF)),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE6EAF2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF285CCC), width: 2),
                ),
              ),
            ),
          ),

          // ─── Privacy label ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.lock_rounded, size: 14, color: Color(0xFF9CA3AF)),
                SizedBox(width: 4),
                Text(
                  'Only you can see these entries',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          // ─── Entries List / Empty State ────────────────────────────────
          Expanded(
            child: Consumer<PartyProvider>(
              builder: (context, provider, _) {
                if (provider.isLedgerLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF285CCC)));
                }
                final entries = _filtered(provider.currentLedgerEntries);
                if (entries.isEmpty && _searchQuery.isEmpty) {
                  return _EmptyLedgerState(
                    party: _party,
                    onYouGave: () => _openAddEntry(EntryType.youGave),
                    onYouGot: () => _openAddEntry(EntryType.youGot),
                  );
                }
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'No entries match your search.',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Column headers
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text('Entries',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                )),
                          ),
                          Expanded(
                            child: Text('Given',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                )),
                          ),
                          Expanded(
                            child: Text('Received',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF22C55E),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        itemCount: entries.length,
                        itemBuilder: (context, index) =>
                            _LedgerEntryTile(entry: entries[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // ─── Bottom Action Buttons ──────────────────────────────────────────
      bottomNavigationBar: _LedgerBottomBar(
        party: _party,
        onYouGave: () => _openAddEntry(EntryType.youGave),
        onYouGot: () => _openAddEntry(EntryType.youGot),
      ),
    );
  }

  void _openAddEntry(EntryType type) {
    final provider = context.read<PartyProvider>();
    Navigator.pushNamed(
      context,
      AppRoutes.addEntry,
      arguments: {'party': _party, 'entryType': type},
    ).then((_) {
      // Refresh ledger and party balance
      provider.loadLedgerEntries(_party.id);
      provider.loadParties();
    });
  }
}

// ─── Ledger App Bar ────────────────────────────────────────────────────────────
class _LedgerAppBar extends StatelessWidget {
  final PartyModel party;
  const _LedgerAppBar({required this.party});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF285CCC), Color(0xFF1F4AB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            party.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            party.isCustomer ? 'Customer' : 'Supplier',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Click here to view settings',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Call icon
              if (party.phone != null && party.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.call_rounded, color: Colors.white),
                  onPressed: () async {
                    final Uri launchUri = Uri(scheme: 'tel', path: party.phone);
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not launch dialer')),
                        );
                      }
                    }
                  },
                ),
              // Overflow menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, party);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit', child: Text('Edit Party')),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: Color(0xFFEF4444)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PartyModel party) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${party.name}?',
            style: const TextStyle(fontFamily: 'Poppins')),
        content: const Text(
            'This will delete all ledger entries for this party.',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<PartyProvider>();
              await provider.deleteParty(party.id, party.type);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─── Balance Card ──────────────────────────────────────────────────────────────
class _LedgerBalanceCard extends StatelessWidget {
  final PartyModel party;
  const _LedgerBalanceCard({required this.party});

  @override
  Widget build(BuildContext context) {
    final isGet = party.balance >= 0;
    final color =
        isGet ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final label =
        isGet ? "You'll Get" : "You'll Give";

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Rs ${party.balance.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Bar ──────────────────────────────────────────────────────────
class _QuickActionBar extends StatelessWidget {
  final PartyModel party;
  const _QuickActionBar({required this.party});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickAction(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Report',
              iconColor: const Color(0xFFF59E0B),
              onTap: () async {
                final provider = context.read<PartyProvider>();
                if (provider.currentLedgerEntries.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No entries to generate report.')),
                  );
                  return;
                }
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating Report...')),
                  );
                  await PdfExportService.generateAndShareLedgerReport(
                    party,
                    provider.currentLedgerEntries,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error generating report: $e')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: Icons.notifications_rounded,
              label: 'Reminder',
              iconColor: const Color(0xFF9CA3AF),
              onTap: () async {
                if (party.phone == null || party.phone!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No phone number added for this party.')),
                  );
                  return;
                }
                final balanceLabel = party.balance >= 0 ? "You'll Get" : "You'll Give";
                final body = "Hi ${party.name}, this is a reminder regarding your balance. $balanceLabel Rs ${party.balance.abs().toStringAsFixed(0)}.";
                final Uri launchUri = Uri(scheme: 'sms', path: party.phone, queryParameters: {'body': body});
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch SMS app')),
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickAction(
              icon: Icons.sms_rounded,
              label: 'SMS',
              iconColor: const Color(0xFF9CA3AF),
              onTap: () async {
                if (party.phone == null || party.phone!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No phone number added for this party.')),
                  );
                  return;
                }
                final Uri launchUri = Uri(scheme: 'sms', path: party.phone);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch SMS app')),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ledger Entry Tile ─────────────────────────────────────────────────────────
class _LedgerEntryTile extends StatelessWidget {
  final LedgerEntryModel entry;
  const _LedgerEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCredit = entry.isCredit;
    final creditColor = const Color(0xFF22C55E);
    final debitColor = const Color(0xFFEF4444);
    final entryColor = isCredit ? creditColor : debitColor;
    final bgColor = isCredit
        ? const Color(0xFFDCFCE7).withValues(alpha: 0.5)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date/time + note column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, dd MMM yy • hh:mm a')
                      .format(entry.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                if (entry.items.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF3FC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${entry.items.length} Item${entry.items.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF285CCC),
                      ),
                    ),
                  ),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.note!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                // Balance chip
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: entryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Bal. Rs${entry.balanceAfter.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: entryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Debit amount (You Gave)
          Expanded(
            child: entry.isDebit
                ? Center(
                    child: Text(
                      entry.amount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Credit amount (You Got)
          Expanded(
            child: entry.isCredit
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      entry.amount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Ledger State ────────────────────────────────────────────────────────
class _EmptyLedgerState extends StatelessWidget {
  final PartyModel party;
  final VoidCallback onYouGave;
  final VoidCallback onYouGot;

  const _EmptyLedgerState({
    required this.party,
    required this.onYouGave,
    required this.onYouGot,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2BD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 56,
                color: Color(0xFF285CCC),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No entries yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first entry below',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _EntryButton(
                  label: 'You Gave',
                  color: const Color(0xFFEF4444),
                  icon: Icons.arrow_upward_rounded,
                  onTap: onYouGave,
                ),
                const SizedBox(width: 16),
                _EntryButton(
                  label: 'You Got',
                  color: const Color(0xFF22C55E),
                  icon: Icons.arrow_downward_rounded,
                  onTap: onYouGot,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _EntryButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

// ─── Bottom Action Bar ─────────────────────────────────────────────────────────
class _LedgerBottomBar extends StatelessWidget {
  final PartyModel party;
  final VoidCallback onYouGave;
  final VoidCallback onYouGot;

  const _LedgerBottomBar({
    required this.party,
    required this.onYouGave,
    required this.onYouGot,
  });

  @override
  Widget build(BuildContext context) {
    // For customers: You Gave = debit (red), You Got = credit (green)
    // For suppliers: Purchase (green), Payment (red) — but we use same model
    final isCustomer = party.isCustomer;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onYouGave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCustomer
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isCustomer ? 'YOU GAVE' : 'PURCHASE  Rs',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onYouGot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isCustomer ? 'YOU GOT' : 'PAYMENT  Rs',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
