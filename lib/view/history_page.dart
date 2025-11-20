import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/model/collection_result.dart';
import 'package:flashcard_app/provider/firestore_collection_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<CollectionResult>>? futureHistory;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          futureHistory = FirestoreCollectionResultProvider.helper
              .getUserHistory(state.username);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "Histórico",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<CollectionResult>>(
          future: futureHistory,
          builder: (context, snapshot) {
            final history = snapshot.data;
            if (history!.isEmpty) {
              return Text("Você ainda não completou nenhuma coleção!");
            }

            return Column(
              children: history.map((result) {
                return ListTile(
                  title: Text(result.collectionTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Coleção: ${result.collectionTitle}"),
                      Text("Respostas corretas: ${result.rightAnswers}"),
                      Text("Respostas erradas: ${result.wrongAnswers}"),
                      Text("Porcentagem de acerto: ${result.wrongAnswers}%"),
                      Text("Data: ${result.resolvedAt}"),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
