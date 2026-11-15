import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../../shared/widgets/specialist_card.dart';
import '../viewmodels/specialist_list_view_model.dart';

/// Pantalla de REFERENCIA de lista remota: búsqueda, pull-to-refresh y los 4 estados.
class SpecialistsPage extends StatefulWidget {
  const SpecialistsPage({super.key});

  @override
  State<SpecialistsPage> createState() => _SpecialistsPageState();
}

class _SpecialistsPageState extends State<SpecialistsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpecialistListViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Especialistas')),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: vm.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o especialidad',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: vm.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              vm.search('');
                            },
                          ),
                  ),
                ),
              ),
              Expanded(
                child: AsyncStateView(
                  status: vm.status,
                  errorMessage: vm.errorMessage,
                  canRetry: vm.canRetry,
                  onRetry: vm.load,
                  emptyMessage: 'No encontramos especialistas.',
                  emptyIcon: Icons.search_off,
                  dataBuilder: (_) => RefreshIndicator(
                    onRefresh: vm.load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.lg),
                      itemCount: vm.specialists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final s = vm.specialists[i];
                        return SpecialistCard(
                          specialist: s,
                          onTap: () => context.push(AppRoutes.specialistDetail(s.id)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
