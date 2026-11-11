
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 255,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.pastelGradient,
        border: Border(
          right: BorderSide(color: AppTheme.softLilac),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 18, 28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _menuItem(
              index: 0,
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Dashboard',
            ),

            _menuItem(
              index: 1,
              icon: Icons.people_outline_rounded,
              activeIcon: Icons.people_rounded,
              label: 'User Management',
            ),

            _menuItem(
              index: 2,
              icon: Icons.history_rounded,
              activeIcon: Icons.history_rounded,
              label: 'Activity History',
            ),

            const Spacer(),

            // Decorative cat illustration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Image.asset(
                  'assets/images/cat_heart.png',
                  width: 165,
                  height: 145,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 19,
                ),
                label: const Text('Log Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  minimumSize: const Size(
                    double.infinity,
                    46,
                  ),
                  side: const BorderSide(
                    color: AppTheme.softLilac,
                  ),
                  backgroundColor: Colors.white.withValues(
                    alpha: 0.75,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.85)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelect(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  size: 21,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
