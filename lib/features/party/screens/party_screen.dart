import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/party_provider.dart';
import '../models/party_model.dart';
import '../models/bank_account_model.dart';
import '../../../routes/app_routes.dart';

/// Party Screen — 4 tabs: Customers / Suppliers / Banks / All
/// Per agents.md: top bar, balance summary card, list, FAB to add party.
class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load parties when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PartyProvider>();
      provider.loadParties();
      provider.loadBanks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          // ─── Custom AppBar with Blue gradient ─────────────────────────
          _PartyAppBar(
            tabController: _tabController,
            balanceVisible: _balanceVisible,
            onToggleBalance: () =>
                setState(() => _balanceVisible = !_balanceVisible),
          ),

          // ─── Tab Content ──────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CustomersTab(balanceVisible: _balanceVisible),
                _SuppliersTab(balanceVisible: _balanceVisible),
                _BanksTab(),
                _AllTab(balanceVisible: _balanceVisible),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _PartyFab(tabController: _tabController),
    );
  }
}

// ─── App Bar with gradient header + tabs ──────────────────────────────────────
class _PartyAppBar extends StatelessWidget {
  final TabController tabController;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  const _PartyAppBar({
    required this.tabController,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

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
        child: Column(
          children: [
            // Title row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Party',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Collection button
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Collection feature coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                    ),
                    child: const Text(
                      'COLLECTION',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: tabController,
              indicatorColor: const Color(0xFFFFF2BD),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Customers'),
                Tab(text: 'Suppliers'),
                Tab(text: 'Banks'),
                Tab(text: 'All'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Balance Summary Card ─────────────────────────────────────────────────────
class _BalanceSummaryCard extends StatelessWidget {
  final double youWillGive;
  final double youWillGet;
  final bool visible;
  final VoidCallback onToggle;

  const _BalanceSummaryCard({
    required this.youWillGive,
    required this.youWillGet,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle label
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Icon(
                  visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 16,
                  color: const Color(0xFF285CCC),
                ),
                const SizedBox(width: 6),
                Text(
                  visible ? 'Hide Balance' : 'Show Balance',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF285CCC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'You will give',
                  amount: youWillGive,
                  color: const Color(0xFFEF4444),
                  visible: visible,
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: const Color(0xFFE6EAF2),
              ),
              Expanded(
                child: _BalanceStat(
                  label: 'You will get',
                  amount: youWillGet,
                  color: const Color(0xFF22C55E),
                  visible: visible,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: const Color(0xFF285CCC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool visible;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visible ? 'Rs ${amount.toStringAsFixed(0)}' : 'Rs ****',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
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
    );
  }
}

// ─── Customers Tab ─────────────────────────────────────────────────────────────
class _CustomersTab extends StatelessWidget {
  final bool balanceVisible;
  const _CustomersTab({required this.balanceVisible});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF285CCC)));
        }
        return Column(
          children: [
            _BalanceSummaryCard(
              youWillGive: provider.customerTotalGive,
              youWillGet: provider.customerTotalGet,
              visible: balanceVisible,
              onToggle: () {}, // toggle handled at parent
            ),
            const SizedBox(height: 8),
            if (provider.customers.isEmpty)
              Expanded(
                child: _EmptyPartyState(
                  type: PartyType.customer,
                  onAdd: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addParty,
                    arguments: PartyType.customer,
                  ).then((_) => provider.loadParties()),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: provider.customers.length,
                  itemBuilder: (context, index) => _PartyListTile(
                    party: provider.customers[index],
                    balanceVisible: balanceVisible,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Suppliers Tab ─────────────────────────────────────────────────────────────
class _SuppliersTab extends StatelessWidget {
  final bool balanceVisible;
  const _SuppliersTab({required this.balanceVisible});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF285CCC)));
        }
        return Column(
          children: [
            _BalanceSummaryCard(
              youWillGive: provider.supplierTotalGive,
              youWillGet: provider.supplierTotalGet,
              visible: balanceVisible,
              onToggle: () {},
            ),
            const SizedBox(height: 8),
            if (provider.suppliers.isEmpty)
              Expanded(
                child: _EmptyPartyState(
                  type: PartyType.supplier,
                  onAdd: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addParty,
                    arguments: PartyType.supplier,
                  ).then((_) => provider.loadParties()),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: provider.suppliers.length,
                  itemBuilder: (context, index) => _PartyListTile(
                    party: provider.suppliers[index],
                    balanceVisible: balanceVisible,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Banks Tab ────────────────────────────────────────────────────────────────
class _BanksTab extends StatelessWidget {
  const _BanksTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            if (provider.banks.isEmpty)
              Expanded(
                child: _EmptyBanksState(
                  onAdd: () => Navigator.pushNamed(
                    context,
                    AppRoutes.bankAccount,
                  ).then((_) => provider.loadBanks()),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: provider.banks.length,
                  itemBuilder: (context, index) =>
                      _BankListTile(bank: provider.banks[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── All Tab ──────────────────────────────────────────────────────────────────
class _AllTab extends StatelessWidget {
  final bool balanceVisible;
  const _AllTab({required this.balanceVisible});

  @override
  Widget build(BuildContext context) {
    return Consumer<PartyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF285CCC)));
        }
        final all = provider.allParties;
        if (all.isEmpty) {
          return const Center(
            child: Text(
              'No parties yet.\nAdd customers or suppliers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Color(0xFF6B7280),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: all.length,
          itemBuilder: (context, index) => _PartyListTile(
            party: all[index],
            balanceVisible: balanceVisible,
            showTypeBadge: true,
          ),
        );
      },
    );
  }
}

// ─── Party List Tile ──────────────────────────────────────────────────────────
class _PartyListTile extends StatelessWidget {
  final PartyModel party;
  final bool balanceVisible;
  final bool showTypeBadge;

  const _PartyListTile({
    required this.party,
    required this.balanceVisible,
    this.showTypeBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = party.balance >= 0;
    final balanceColor =
        isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final balanceLabel =
        isPositive ? 'You will get' : 'You will give';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEEF3FC),
          child: Text(
            party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF285CCC),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                party.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showTypeBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: party.isCustomer
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  party.isCustomer ? 'Customer' : 'Supplier',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: party.isCustomer
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF285CCC),
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: party.phone != null
            ? Text(
                '${party.countryCode ?? '+92'} ${party.phone}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              balanceVisible
                  ? 'Rs ${party.balance.abs().toStringAsFixed(0)}'
                  : 'Rs ****',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: balanceColor,
              ),
            ),
            Text(
              balanceLabel,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        onTap: () {
          final provider = context.read<PartyProvider>();
          final route = party.isCustomer
              ? AppRoutes.customerLedger
              : AppRoutes.supplierLedger;
          Navigator.pushNamed(context, route, arguments: party).then(
            (_) => provider.loadParties(),
          );
        },
      ),
      ),
    );
  }
}

// ─── Bank List Tile ────────────────────────────────────────────────────────────
class _BankListTile extends StatelessWidget {
  final BankAccountModel bank;
  const _BankListTile({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Color(0xFF285CCC),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.bankName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bank.accountTitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  bank.accountNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

// ─── Empty State for Customers/Suppliers ──────────────────────────────────────
class _EmptyPartyState extends StatelessWidget {
  final PartyType type;
  final VoidCallback onAdd;

  const _EmptyPartyState({required this.type, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isCustomer = type == PartyType.customer;
    final steps = isCustomer
        ? ['Add customers', 'Add entries & maintain khata', 'Send payment reminders']
        : ['Add suppliers', 'Track purchases & payments', 'Manage payables easily'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Illustration placeholder
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2BD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCustomer ? Icons.people_alt_rounded : Icons.store_rounded,
              size: 72,
              color: const Color(0xFF285CCC),
            ),
          ),
          const SizedBox(height: 24),
          // Steps
          ...steps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF3FC),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF285CCC),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Empty State for Banks ────────────────────────────────────────────────────
class _EmptyBanksState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBanksState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF3FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              size: 56,
              color: Color(0xFF285CCC),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No bank accounts yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your bank accounts to keep\ntrack of your balances.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Floating Action Button (context-aware per tab) ────────────────────────────
class _PartyFab extends StatefulWidget {
  final TabController tabController;
  const _PartyFab({required this.tabController});

  @override
  State<_PartyFab> createState() => _PartyFabState();
}

class _PartyFabState extends State<_PartyFab> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      if (mounted) setState(() => _currentIndex = widget.tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't show FAB on "All" tab (index 3)
    if (_currentIndex == 3) return const SizedBox.shrink();

    final labels = ['Customer', 'Supplier', 'Bank Account'];
    final icons = [
      Icons.person_add_rounded,
      Icons.store_rounded,
      Icons.account_balance_rounded,
    ];
    final routes = [AppRoutes.addParty, AppRoutes.addParty, AppRoutes.bankAccount];
    final args = [
      PartyType.customer,
      PartyType.supplier,
      null,
    ];

    return FloatingActionButton.extended(
      onPressed: () {
        final provider = context.read<PartyProvider>();
        final idx = _currentIndex;
        Navigator.pushNamed(
          context,
          routes[idx],
          arguments: args[idx],
        ).then((_) {
          if (idx == 2) {
            provider.loadBanks();
          } else {
            provider.loadParties();
          }
        });
      },
      backgroundColor: const Color(0xFF285CCC),
      foregroundColor: Colors.white,
      icon: Icon(icons[_currentIndex]),
      label: Text(
        'Add ${labels[_currentIndex]}',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
