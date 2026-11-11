
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/auth_service.dart';
import '../services/activity_log_service.dart';
import '../services/user_service.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/user_table.dart';
import '../widgets/user_form_dialog.dart';
import '../widgets/delete_user_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final _userService = UserService();
  final _logService = ActivityLogService();

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _userStream = _userService.getUsers();

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      _logStream = _logService.watchLogs();

  String get _pageTitle {
    switch (selectedIndex) {
      case 1:
        return 'User Management';
      case 2:
        return 'Activity History';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.snowWhite,
      drawer: desktop
          ? null
          : Drawer(
              child: AppSidebar(
                selectedIndex: selectedIndex,
                onSelect: (index) {
                  Navigator.pop(context);
                  setState(() => selectedIndex = index);
                },
                onLogout: _logout,
              ),
            ),
      body: Row(
        children: [
          if (desktop)
            AppSidebar(
              selectedIndex: selectedIndex,
              onSelect: (index) {
                setState(() => selectedIndex = index);
              },
              onLogout: _logout,
            ),

          Expanded(
            child: Column(
              children: [
                _header(desktop),

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Cannot load users: ${snapshot.error}',
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        );
                      }

                      final users = snapshot.data!.docs.map((doc) {
                        final data = doc.data();

                        return <String, String>{
                          'id': doc.id,
                          'name': (data['hoten'] ?? '').toString(),
                          'email': (data['email'] ?? '').toString(),
                          'hinhanh':
                              (data['hinhanh'] ?? '').toString(),
                          'status': 'Active',
                        };
                      }).toList();

                      return StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: _logStream,
                        builder: (context, logSnapshot) {
                          final logs = logSnapshot.data?.docs ?? [];

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(22),
                            child: _pageContent(
                              users,
                              logs,
                              logSnapshot.hasError
                                  ? logSnapshot.error.toString()
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header: one page title only, no notifications.
  Widget _header(bool desktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          if (!desktop)
            Builder(
              builder: (context) => IconButton(
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),

          Expanded(
            child: Text(
              _pageTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          const CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.softLilac,
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
          ),

          if (desktop) ...[
            const SizedBox(width: 10),
            const Text(
              'Admin',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Three separate pages.
  Widget _pageContent(
    List<Map<String, String>> users,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> logs,
    String? logError,
  ) {
    switch (selectedIndex) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manage your users',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                _addUserButton(),
              ],
            ),

            const SizedBox(height: 18),

            UserTable(
              users: users,
              onEdit: _editUser,
              onDelete: _deleteUser,
            ),
          ],
        );

      case 2:
        return _activityCard(
          logs,
          showAll: true,
          error: logError,
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeBanner(),
            const SizedBox(height: 20),
            _userChart(users),
            const SizedBox(height: 20),
            _activityCard(
              logs,
              showAll: false,
              error: logError,
            ),
          ],
        );
    }
  }

  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.pastelGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Here is your user management overview.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Image.asset(
            'assets/images/cat_heart.png',
            width: 110,
            height: 110,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _userChart(List<Map<String, String>> users) {
    final total = users.length;

    final withPhoto = users
        .where(
          (user) => (user['hinhanh'] ?? '').isNotEmpty,
        )
        .length;

    final withoutPhoto = total - withPhoto;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Overview',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Profile picture distribution',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final chart = SizedBox(
                width: 220,
                height: 220,
                child: total == 0
                    ? const Center(
                        child: Text(
                          'No users yet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          centerSpaceRadius: 56,
                          sectionsSpace: 3,
                          startDegreeOffset: -90,
                          sections: [
                            if (withPhoto > 0)
                              PieChartSectionData(
                                value: withPhoto.toDouble(),
                                color: AppTheme.primary,
                                radius: 34,
                                showTitle: false,
                              ),
                            if (withoutPhoto > 0)
                              PieChartSectionData(
                                value: withoutPhoto.toDouble(),
                                color: AppTheme.cloudBlue,
                                radius: 34,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
              );

              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const Text(
                    'Total Users',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _legendRow(
                    'With profile picture',
                    withPhoto,
                    AppTheme.primary,
                  ),

                  const SizedBox(height: 13),

                  _legendRow(
                    'Without profile picture',
                    withoutPhoto,
                    AppTheme.cloudBlue,
                  ),
                ],
              );

              if (constraints.maxWidth < 490) {
                return Column(
                  children: [
                    chart,
                    const SizedBox(height: 18),
                    legend,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  chart,
                  const SizedBox(width: 38),
                  Flexible(child: legend),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _legendRow(
    String title,
    int count,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Text(
            '$title: $count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> logs, {
    required bool showAll,
    String? error,
  }) {
    final visible = showAll
        ? logs
        : logs.take(5).toList();

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showAll
                      ? 'All Activities'
                      : 'Recent Activities',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              if (!showAll)
                TextButton(
                  onPressed: () {
                    setState(() => selectedIndex = 2);
                  },
                  child: const Text('View All'),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (error != null)
            Text(
              'Cannot load activity history: $error',
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
              ),
            )
          else if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Text(
                  'No activities yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ...visible.map(
              (doc) => _activityRow(doc.data()),
            ),
        ],
      ),
    );
  }

  Widget _activityRow(Map<String, dynamic> data) {
    final action = (data['action'] ?? '').toString();

    final description =
        (data['description'] ?? '').toString();

    final admin =
        (data['adminEmail'] ?? 'Admin').toString();

    IconData icon;

    switch (action) {
      case 'LOGIN':
        icon = Icons.login_rounded;
        break;
      case 'LOGOUT':
        icon = Icons.logout_rounded;
        break;
      case 'CREATE':
        icon = Icons.person_add_alt_1_rounded;
        break;
      case 'UPDATE':
        icon = Icons.edit_rounded;
        break;
      case 'DELETE':
        icon = Icons.delete_outline_rounded;
        break;
      default:
        icon = Icons.history_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.softLilac),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.softLilac,
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$admin · ${_formatTime(data['timestamp'])}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            action,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic value) {
    if (value is! Timestamp) {
      return 'Just now';
    }

    final date = value.toDate().toLocal();

    String two(int number) =>
        number.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}'
        ' ${two(date.hour)}:${two(date.minute)}';
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.softLilac),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lavender.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _addUserButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton.icon(
        onPressed: _addUser,
        icon: const Icon(
          Icons.add_rounded,
          size: 19,
        ),
        label: const Text('Add User'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Future<void> _addUser() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const UserFormDialog(),
    );

    if (!mounted || result == null) return;

    try {
      await _userService.addUser(
        hoten: result['name'] as String,
        email: result['email'] as String,
        password: result['password'] as String,
        imageBytes: result['imageBytes'] as Uint8List?,
      );

      if (mounted) {
        _showMessage('User added successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Add failed: $e');
      }
    }
  }

  Future<void> _editUser(Map<String, String> user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => UserFormDialog(user: user),
    );

    if (!mounted || result == null) return;

    try {
      await _userService.updateUser(
        id: user['id']!,
        hoten: result['name'] as String,
        email: result['email'] as String,
        password: result['password'] as String,
        imageBytes: result['imageBytes'] as Uint8List?,
        removeImage: result['removeImage'] == true,
      );

      if (mounted) {
        _showMessage('User updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Update failed: $e');
      }
    }
  }

  Future<void> _deleteUser(
    Map<String, String> user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteUserDialog(
        userName: user['name'] ?? 'this user',
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await _userService.deleteUser(user['id']!);

      if (mounted) {
        _showMessage('User deleted successfully.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Delete failed: $e');
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Log Out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await AuthService().signOut();
    } catch (e) {
      if (mounted) {
        _showMessage('Logout failed: $e');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
