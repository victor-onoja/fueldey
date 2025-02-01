import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/logic/auth_bloc.dart';
import '../../auth/logic/auth_repo.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/logic/user_model.dart';
import '../fuel_station/fuel_station_model.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users', icon: Icon(Icons.people)),
              Tab(text: 'Stations', icon: Icon(Icons.local_gas_station)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UserManagementTab(),
            _StationManagementTab(),
          ],
        ),
      ),
    );
  }
}

class _UserManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildUserList(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(BuildContext context) {
    // In a real app, this would be fetched from your user repository
    final List<UserModel> users = [];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            title: Text(user.username),
            subtitle: Text(user.phoneNumber),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(context, value, user),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                const PopupMenuItem(
                  value: 'change_role',
                  child: Text('Change Role'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleUserAction(BuildContext context, String action, UserModel user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'delete':
        _showDeleteUserDialog(context, user);
        break;
      case 'change_role':
        _showChangeRoleDialog(context, user);
        break;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();
    UserRole selectedRole = UserRole.regular;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              onChanged: (value) {
                selectedRole = value!;
              },
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authRepo = context.read<AuthRepository>();
                await authRepo.createUser(
                  username: usernameController.text,
                  phoneNumber: phoneController.text,
                );
                // Update role if not regular
                if (selectedRole != UserRole.regular) {
                  await authRepo.updateUserRole(
                    uid:
                        'NEW_USER_ID', // You'll need to get this from the creation response
                    newRole: selectedRole,
                  );
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final usernameController = TextEditingController(text: user.username);
    final phoneController = TextEditingController(text: user.phoneNumber);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              value: selectedRole,
              onChanged: (value) {
                selectedRole = value!;
              },
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update user role if changed
                if (selectedRole != user.role) {
                  await context.read<AuthRepository>().updateUserRole(
                        uid: user.uid,
                        newRole: selectedRole,
                      );
                }
                // Add user info update logic
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                // Add delete user logic
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, UserModel user) {
    // Implement change role dialog
  }
}

class _StationManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Station Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddStationDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Station'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildStationList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStationList(BuildContext context) {
    // In a real app, this would be fetched from your station repository
    final List<FuelStation> stations = [];

    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return Card(
          child: ListTile(
            title: Text(station.name),
            subtitle: Text(station.address),
            trailing: PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleStationAction(context, value, station),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                const PopupMenuItem(
                  value: 'assign_moderator',
                  child: Text('Assign Moderator'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStationAction(
      BuildContext context, String action, FuelStation station) {
    switch (action) {
      case 'edit':
        _showEditStationDialog(context, station);
        break;
      case 'delete':
        _showDeleteStationDialog(context, station);
        break;
      case 'assign_moderator':
        _showAssignModeratorDialog(context, station);
        break;
    }
  }

  void _showAddStationDialog(BuildContext context) {
    // Implement add station dialog
  }

  void _showEditStationDialog(BuildContext context, FuelStation station) {
    // Implement edit station dialog
  }

  void _showDeleteStationDialog(BuildContext context, FuelStation station) {
    // Implement delete station confirmation dialog
  }

  void _showAssignModeratorDialog(BuildContext context, FuelStation station) {
    // Implement assign moderator dialog
  }
}
