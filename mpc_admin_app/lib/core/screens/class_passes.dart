import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/bloc/class%20passes/cubit.dart';
import 'package:mpc_admin_app/app/bloc/class%20passes/state.dart';
import 'package:mpc_admin_app/app/models/class_pass.dart';

class ClassPassesScreen extends StatefulWidget {
  const ClassPassesScreen({super.key});

  @override
  State<ClassPassesScreen> createState() => _ClassPassesScreenState();
}

class _ClassPassesScreenState extends State<ClassPassesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassPassesCubit>().loadPasses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClassPassesCubit, ClassPassesState>(
        listener: (context, state) {
          if (state is ClassPassesLoaded && state.notice != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.notice!)));
          }
          if (state is ClassPassesError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is ClassPassesLoading || state is ClassPassesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ClassPassesError) {
            return _buildError(state.message);
          }

          final loaded = state as ClassPassesLoaded;
          return _buildLoaded(loaded);
        },
      ),
      floatingActionButton: BlocBuilder<ClassPassesCubit, ClassPassesState>(
        builder: (context, state) {
          final products =
              state is ClassPassesLoaded ? state.products : <ClassPassProduct>[];
          if (products.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _openGrantSheet(products),
            icon: const Icon(Icons.card_giftcard),
            label: const Text('GRANT PASS'),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const Gap(12),
            Text(message, textAlign: TextAlign.center),
            const Gap(16),
            FilledButton(
              onPressed: () => context.read<ClassPassesCubit>().loadPasses(),
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(ClassPassesLoaded state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ClassPassesCubit>().loadPasses();
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) =>
                context.read<ClassPassesCubit>().loadPasses(search: value.trim()),
          ),
        ),
        Expanded(
          child: state.passes.isEmpty
              ? Center(
                  child: Text(
                    state.search.isEmpty
                        ? 'Nobody holds a pass yet.'
                        : 'No passes for "${state.search}".',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context
                      .read<ClassPassesCubit>()
                      .loadPasses(search: state.search),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: state.passes.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) =>
                        _buildPassCard(state.passes[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPassCard(ClassPass pass) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pass.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        pass.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: pass.status),
              ],
            ),
            const Gap(12),
            Text('${pass.productName} · ${pass.priceLabel}'),
            Text(
              pass.isActive
                  ? 'Expires ${pass.validUntilDate}'
                  : 'Ran ${pass.validFromDate} → ${pass.validUntilDate}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    pass.isBillingRecurring
                        ? Icons.autorenew
                        : Icons.money_off_csred_outlined,
                    size: 14,
                  ),
                  const Gap(4),
                  Text(
                    pass.billingLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (pass.grantedByAdmin)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Granted manually',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Gap(12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      context.read<ClassPassesCubit>().resendLink(pass),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Resend link'),
                ),
                if (pass.isRevoked)
                  TextButton.icon(
                    onPressed: () =>
                        context.read<ClassPassesCubit>().setRevoked(pass, false),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Un-revoke'),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _confirmRevoke(pass),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Revoke'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRevoke(ClassPass pass) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Revoke ${pass.fullName}\'s pass?'),
        // Says exactly what revoke does, because the surprising part is what it
        // does NOT do: classes already booked are left alone.
        content: Text(
          'They will not be able to book any more classes.\n\n'
          'Classes they have already booked still stand — remove them from a '
          'class in the editor if you want the spot back.\n\n'
          // The irreversible half. Un-revoke restores the pass but cannot
          // restart the subscription: that would need their card (D19).
          '${pass.isBillingRecurring ? 'Their monthly payments stop immediately, and cannot be restarted from here — they would have to buy again.\n\n' : ''}'
          'You can un-revoke this at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('REVOKE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ClassPassesCubit>().setRevoked(pass, true);
    }
  }

  Future<void> _openGrantSheet(List<ClassPassProduct> products) async {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    var productId = products.first.id;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (builderContext, setSheetState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grant a pass',
                    style: Theme.of(builderContext).textTheme.titleLarge),
                const Gap(4),
                const Text(
                  'For when payment went through but the pass never arrived. '
                  'The term starts today and the link is emailed to them.',
                ),
                const Gap(16),
                DropdownButtonFormField<String>(
                  initialValue: productId,
                  decoration: const InputDecoration(
                    labelText: 'Pass',
                    border: OutlineInputBorder(),
                  ),
                  items: products
                      .map((product) => DropdownMenuItem(
                            value: product.id,
                            child: Text(
                              '${product.name} · €${(product.priceCents / 100).toStringAsFixed(0)}',
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setSheetState(() => productId = value ?? productId),
                ),
                const Gap(12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email is required';
                    if (!text.contains('@')) return 'That does not look like an email';
                    return null;
                  },
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;
                      Navigator.of(sheetContext).pop();
                      context.read<ClassPassesCubit>().grantPass(
                            productId: productId,
                            email: emailController.text.trim(),
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                          );
                    },
                    child: const Text('GRANT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color color, String label) = switch (status) {
      'active' => (Colors.green, 'ACTIVE'),
      'revoked' => (scheme.error, 'REVOKED'),
      _ => (Colors.grey, 'EXPIRED'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
