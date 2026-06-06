/// Centralized UI copy. No hardcoded user-facing strings elsewhere in the app.
class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'Drilling Activity Tracker';

  // Home
  static const String tabOffline = 'Offline';
  static const String tabOnline = 'Online';
  static const String emptyOfflineTitle = 'No drafts yet';
  static const String emptyOfflineMessage =
      'Saved drafts will appear here. Tap + to record a drilling activity.';
  static const String emptyOnlineTitle = 'No submitted activities';
  static const String emptyOnlineMessage =
      'Submitted activities will appear here once you submit a form.';
  static const String fabNewActivity = 'New Activity';

  // Activity card
  static const String labelHoleId = 'Hole ID';
  static const String labelDate = 'Date';
  static const String menuEdit = 'Edit';
  static const String menuDelete = 'Delete';

  // Delete confirmation
  static const String deleteTitle = 'Delete activity?';
  static const String deleteMessage =
      'This drilling activity will be permanently removed.';
  static const String actionCancel = 'Cancel';
  static const String actionDelete = 'Delete';

  // Form screen
  static const String formTitleNew = 'New Drilling Activity';
  static const String formTitleEdit = 'Edit Drilling Activity';
  static const String fieldDate = 'Date';
  static const String fieldDateHint = 'Select a date';
  static const String fieldHoleId = 'Hole ID';
  static const String fieldHoleIdHint = 'e.g. DH-001';
  static const String fieldAccelerometer = 'Accelerometer';
  static const String fieldGyroscope = 'Gyroscope';
  static const String fieldStatus = 'Status';
  static const String fieldStatusHint = 'Select status';
  static const String fieldImage = 'Take a Picture';

  // Sensor reader
  static const String btnReadSensor = 'Read';
  static const String btnReadSensorAgain = 'Read again';
  static const String sensorX = 'X';
  static const String sensorY = 'Y';
  static const String sensorZ = 'Z';
  static const String sensorNoReading = 'No reading yet';

  // Image picker
  static const String btnPickImage = 'Add photo';
  static const String btnReplaceImage = 'Replace photo';
  static const String btnRemoveImage = 'Remove';
  static const String sheetCamera = 'Camera';
  static const String sheetGallery = 'Gallery';
  static const String sheetTitle = 'Choose image source';

  // Completion status options
  static const String statusComplete = 'Complete';
  static const String statusNotComplete = 'Not Complete';

  // Buttons
  static const String btnSaveDraft = 'Save as Draft';
  static const String btnSubmit = 'Submit';

  // Validation
  static const String validationHoleIdRequired = 'Hole ID is required';
  static const String validationDateRequired = 'Date is required';

  // Snackbar feedback
  static const String snackDraftSaved = 'Draft saved successfully';
  static const String snackSubmitted = 'Activity submitted successfully';
  static const String snackSaveError = 'Failed to save activity';
  static const String snackDeleted = 'Activity deleted';
  static const String snackDeleteError = 'Failed to delete activity';
  static const String snackSensorUnavailable = 'Sensor is not available';
  static const String snackImageError = 'Failed to process image';

  // Status badge labels
  static const String badgeDraft = 'Draft';
  static const String badgeSubmitted = 'Submitted';
}
