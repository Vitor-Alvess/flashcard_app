import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/user_bloc.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.user, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserInitial && !userState.user.isLoggedIn) {
      if (widget.user.isLoggedIn) {
        context.read<UserBloc>().add(UpdateUserName(name: widget.user.name));
        context.read<UserBloc>().add(UpdateUserEmail(email: widget.user.email));
        context.read<UserBloc>().add(UpdateUserAge(age: widget.user.age));
        if (widget.user.profilePicturePath != null) {
          context.read<UserBloc>().add(
            UpdateUserProfilePicture(imagePath: widget.user.profilePicturePath),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is Authenticated;

        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final currentUser = userState is UserInitial
                ? userState.user
                : userState is UserLoaded
                ? userState.user
                : userState is UserUpdated
                ? userState.user
                : widget.user;

            if (isAuthenticated && !currentUser.isLoggedIn) {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<UserBloc>().add(
                    LoadUser(email: authState.username),
                  );
                });
              }
            }

            return Scaffold(
              backgroundColor: Colors.black87,
              body: isAuthenticated && currentUser.isLoggedIn
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: currentUser.profilePicturePath != null
                                  ? ClipOval(
                                      child: kIsWeb
                                          ? Image.network(
                                              currentUser.profilePicturePath!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.white,
                                                    );
                                                  },
                                            )
                                          : Image.file(
                                              File(
                                                currentUser.profilePicturePath!,
                                              ),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.white,
                                                    );
                                                  },
                                            ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  Icons.person,
                                  "Nome",
                                  currentUser.name,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.email,
                                  "Email",
                                  currentUser.email,
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.cake,
                                  "Idade",
                                  "${currentUser.age}",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showLogoutDialog(context);
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Deslogar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Você não está logado",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Faça login para ver seu perfil",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text("$label: ", style: TextStyle(color: Colors.white70, fontSize: 16)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "Deslogar",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Tem certeza que deseja sair?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onLogout();
              },
              child: const Text(
                "Deslogar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
