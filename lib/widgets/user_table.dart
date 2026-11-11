
import 'dart:convert';

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class UserTable extends StatefulWidget {
  final List<Map<String, String>> users;
  final void Function(Map<String, String>) onEdit;
  final void Function(Map<String, String>) onDelete;

  const UserTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  String searchQuery = '';
  String sortOrder = 'A-Z';
  int currentPage = 0;

  static const int pageSize = 5;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.users.where((user) {
      final query = searchQuery.trim().toLowerCase();

      return (user['name'] ?? '').toLowerCase().contains(query) ||
          (user['email'] ?? '').toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      final result = (a['name'] ?? '')
          .toLowerCase()
          .compareTo((b['name'] ?? '').toLowerCase());

      return sortOrder == 'A-Z' ? result : -result;
    });

    // Show 0 pages when no users match.
    final totalPages = filtered.isEmpty
        ? 0
        : (filtered.length / pageSize).ceil();

    final page = totalPages == 0
        ? 0
        : currentPage.clamp(0, totalPages - 1);

    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    final visibleUsers = filtered.sublist(start, end);

    final hasSearch = searchQuery.trim().isNotEmpty;
    final hasUsers = widget.users.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.softLilac),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lavender.withValues(alpha: 0.12),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${widget.users.length} users in total',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          // Search and sorting
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    currentPage = 0;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search by name or email...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              );

              final sort = DropdownButtonFormField<String>(
                initialValue: sortOrder,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.sort_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'A-Z',
                    child: Text('Name A-Z'),
                  ),
                  DropdownMenuItem(
                    value: 'Z-A',
                    child: Text('Name Z-A'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    sortOrder = value;
                    currentPage = 0;
                  });
                },
              );

              return constraints.maxWidth < 480
                  ? Column(
                      children: [
                        search,
                        const SizedBox(height: 12),
                        sort,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: search),
                        const SizedBox(width: 14),
                        SizedBox(width: 190, child: sort),
                      ],
                    );
            },
          ),

          const SizedBox(height: 22),

          // Empty state or user list
          if (visibleUsers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 42),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: AppTheme.softLilac,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasSearch && hasUsers
                            ? Icons.search_off_rounded
                            : Icons.people_outline_rounded,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      hasSearch && hasUsers
                          ? 'No matching users'
                          : 'No users yet',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      hasSearch && hasUsers
                          ? 'Try searching with a different name or email.'
                          : 'Add your first user to get started.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...visibleUsers.map(_userRow),

          const SizedBox(height: 22),

          // Pagination
          Row(
            children: [
              Expanded(
                child: Text(
                  filtered.isEmpty
                      ? 'Showing 0 users'
                      : 'Showing ${start + 1}–$end of ${filtered.length}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Previous page',
                onPressed: totalPages > 0 && page > 0
                    ? () {
                        setState(() {
                          currentPage = page - 1;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),

              Text(
                totalPages == 0
                    ? '0 / 0'
                    : '${page + 1} / $totalPages',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              IconButton(
                tooltip: 'Next page',
                onPressed: totalPages > 0 && page < totalPages - 1
                    ? () {
                        setState(() {
                          currentPage = page + 1;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _userRow(Map<String, String> user) {
    final name = user['name'] ?? '';
    final email = user['email'] ?? '';
    final image = user['hinhanh'] ?? '';

    ImageProvider? photo;

    if (image.isNotEmpty) {
      try {
        photo = MemoryImage(base64Decode(image));
      } catch (_) {
        photo = null;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.softLilac),
        ),
      ),
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 23,
            backgroundColor: AppTheme.cloudBlue,
            backgroundImage: photo,
            child: photo == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 14),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status
          if (MediaQuery.sizeOf(context).width >= 650)
            Container(
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.softLilac,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Edit button
          IconButton(
            tooltip: 'Edit user',
            onPressed: () => widget.onEdit(user),
            icon: const Icon(
              Icons.edit_outlined,
              color: AppTheme.primary,
              size: 21,
            ),
          ),

          // Delete button
          IconButton(
            tooltip: 'Delete user',
            onPressed: () => widget.onDelete(user),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.danger,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}
