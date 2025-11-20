import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/history_bloc.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryPage extends StatefulWidget {
  final User user;

  const HistoryPage({super.key, required this.user});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _lastLoadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carregar histórico quando a página é aberta ou quando o usuário muda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          // Só carrega se for um usuário diferente ou se ainda não carregou
          if (_lastLoadedUserId != authState.username) {
            _lastLoadedUserId = authState.username;
            print('Loading history for user: ${authState.username}');
            context.read<HistoryBloc>().add(
              LoadHistory(userId: authState.username),
            );
          }
        } else {
          // Reset quando deslogar
          _lastLoadedUserId = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey[600]),
              const SizedBox(height: 24),
              Text(
                "Faça login para ver seu histórico",
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          if (_lastLoadedUserId != authState.username) {
            _lastLoadedUserId = authState.username;
            print(
              'AuthBloc listener: Loading history for user: ${authState.username}',
            );
            context.read<HistoryBloc>().add(
              LoadHistory(userId: authState.username),
            );
          }
        } else {
          _lastLoadedUserId = null;
          context.read<HistoryBloc>().add(ResetHistory());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return Scaffold(
              backgroundColor: Colors.black87,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 24),
                    Text(
                      "Faça login para ver seu histórico",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black87,
            body: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HistoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Erro ao carregar histórico",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (state is HistoryLoaded) {
                  if (state.histories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Nenhum histórico ainda",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Seus resultados de estudo aparecerão aqui",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.histories.length,
                    itemBuilder: (context, index) {
                      final history = state.histories[index];
                      return _buildHistoryCard(context, history);
                    },
                  );
                }

                // Fallback - mostrar loading
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, history) {
    final formattedDate = _formatDate(history.completedAt);
    final modeText = _getModeText(history.mode);
    final percentageColor = _getPercentageColor(history.percentage);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              history.collectionName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getModeIcon(history.mode),
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  modeText,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${history.correctAnswers}/${history.totalQuestions}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "acertos",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: percentageColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: percentageColor, width: 2),
                  ),
                  child: Text(
                    "${history.percentage}%",
                    style: TextStyle(
                      color: percentageColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  String _getModeText(mode) {
    switch (mode.toString().split('.').last) {
      case 'written':
        return 'Escrita';
      case 'multipleChoice':
        return 'Múltipla Escolha';
      case 'selfAssessment':
        return 'Autoavaliação';
      default:
        return 'Desconhecido';
    }
  }

  IconData _getModeIcon(mode) {
    switch (mode.toString().split('.').last) {
      case 'written':
        return Icons.edit;
      case 'multipleChoice':
        return Icons.radio_button_checked;
      case 'selfAssessment':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 81) {
      return Colors.green;
    } else if (percentage >= 61) {
      return Colors.lightGreen;
    } else if (percentage >= 41) {
      return Colors.orange;
    } else if (percentage >= 21) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
