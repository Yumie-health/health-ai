import 'package:flutter/material.dart';

/// Ensures only one high-priority dialog is shown at a time across the app.
class DialogCoordinator {
  DialogCoordinator._internal();
  static final DialogCoordinator instance = DialogCoordinator._internal();

  bool _isDialogOpen = false;

  bool get isDialogOpen => _isDialogOpen;

  Future<T?> showExclusiveDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = false,
  }) async {
    if (_isDialogOpen) {
      // A dialog is already visible; skip to avoid stacking
      return null;
    }
    _isDialogOpen = true;
    try {
      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
    } finally {
      _isDialogOpen = false;
    }
  }
}


