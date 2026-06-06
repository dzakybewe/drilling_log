import 'package:flutter/foundation.dart';

import '../../../core/constants/db_constants.dart';
import '../../../data/models/drilling_activity.dart';
import '../../../data/repositories/drilling_repository.dart';

/// Drives the Home screen: loads draft (offline) and submitted (online) lists.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final DrillingRepository _repository;

  List<DrillingActivity> _drafts = [];
  List<DrillingActivity> _submitted = [];
  bool _isLoading = false;

  List<DrillingActivity> get drafts => _drafts;
  List<DrillingActivity> get submitted => _submitted;
  bool get isLoading => _isLoading;

  /// Loads both lists from the repository and notifies listeners.
  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    _drafts = await _repository.getByStatus(DbConstants.statusDraft);
    _submitted = await _repository.getByStatus(DbConstants.statusSubmitted);

    _isLoading = false;
    notifyListeners();
  }

  /// Deletes an activity then refreshes the lists. Returns true on success.
  Future<bool> deleteActivity(int id) async {
    try {
      await _repository.delete(id);
      await loadActivities();
      return true;
    } catch (_) {
      return false;
    }
  }
}
