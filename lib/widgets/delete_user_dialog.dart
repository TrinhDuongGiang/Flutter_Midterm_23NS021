
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class DeleteUserDialog extends StatelessWidget {
  final String userName;

  const DeleteUserDialog({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lavender.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.danger,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delete User?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to delete "$userName"? '
              'This action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(
                        color: AppTheme.lavender,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                    ),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
