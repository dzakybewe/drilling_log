import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/drilling_activity.dart';
import '../../data/repositories/drilling_repository.dart';
import 'viewmodels/home_viewmodel.dart';
import 'widgets/activity_card.dart';
import 'widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(context.read<DrillingRepository>()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    // Make sure provider is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadActivities();
    });
  }

  Future<void> _openForm({DrillingActivity? activity}) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.drillingForm,
      arguments: activity,
    );
    if (!mounted) return;
    await context.read<HomeViewModel>().loadActivities();
  }

  Future<void> _confirmDelete(DrillingActivity activity) async {
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<HomeViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTitle),
        content: const Text(AppStrings.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || activity.id == null) return;

    final success = await viewModel.deleteActivity(activity.id!);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? AppStrings.snackDeleted : AppStrings.snackDeleteError,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appTitle),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.tabOffline),
              Tab(text: AppStrings.tabOnline),
            ],
          ),
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _ActivityList(
                  activities: viewModel.drafts,
                  onRefresh: viewModel.loadActivities,
                  onTap: (a) => _openForm(activity: a),
                  onDelete: _confirmDelete,
                  emptyIcon: Icons.drafts_outlined,
                  emptyTitle: AppStrings.emptyOfflineTitle,
                  emptyMessage: AppStrings.emptyOfflineMessage,
                ),
                _ActivityList(
                  activities: viewModel.submitted,
                  onRefresh: viewModel.loadActivities,
                  onTap: (a) => _openForm(activity: a),
                  onDelete: _confirmDelete,
                  emptyIcon: Icons.cloud_done_outlined,
                  emptyTitle: AppStrings.emptyOnlineTitle,
                  emptyMessage: AppStrings.emptyOnlineMessage,
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.fabNewActivity),
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({
    required this.activities,
    required this.onRefresh,
    required this.onTap,
    required this.onDelete,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<DrillingActivity> activities;
  final Future<void> Function() onRefresh;
  final void Function(DrillingActivity) onTap;
  final void Function(DrillingActivity) onDelete;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: activities.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  child: EmptyState(
                    icon: emptyIcon,
                    title: emptyTitle,
                    message: emptyMessage,
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimens.s16),
              itemCount: activities.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.s12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityCard(
                  key: ValueKey(activity.id),
                  activity: activity,
                  onTap: () => onTap(activity),
                  onDelete: () => onDelete(activity),
                );
              },
            ),
    );
  }
}
