import 'package:flutter/material.dart';

class LoadingDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.all(50),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Shows a loading dialog and automatically hides it when the future completes
  static Future<T> showWithFuture<T>(
    BuildContext context, 
    Future<T> future, 
    String message
  ) async {
    show(context, message);
    try {
      final result = await future;
      if (context.mounted) {
        hide(context);
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        hide(context);
      }
      rethrow;
    }
  }
}