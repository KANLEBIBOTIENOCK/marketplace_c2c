import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/chat_usecases.dart';

final chatDatasourceProvider = Provider<ChatRemoteDatasource>(
  (ref) => ChatRemoteDatasource(Supabase.instance.client),
);

final chatRepositoryProvider = Provider<ChatRepositoryImpl>(
  (ref) => ChatRepositoryImpl(ref.watch(chatDatasourceProvider)),
);

final ouvrirConversationUsecaseProvider = Provider(
  (ref) => OuvrirConversationUsecase(ref.watch(chatRepositoryProvider)),
);

final getMesConversationsUsecaseProvider = Provider(
  (ref) => GetMesConversationsUsecase(ref.watch(chatRepositoryProvider)),
);

final getMessagesUsecaseProvider = Provider(
  (ref) => GetMessagesUsecase(ref.watch(chatRepositoryProvider)),
);

final envoyerMessageUsecaseProvider = Provider(
  (ref) => EnvoyerMessageUsecase(ref.watch(chatRepositoryProvider)),
);

final marquerLuUsecaseProvider = Provider(
  (ref) => MarquerLuUsecase(ref.watch(chatRepositoryProvider)),
);

// Liste des conversations de l'utilisateur connecté
final mesConversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  return ref.watch(getMesConversationsUsecaseProvider).call(userId);
});

// Stream des messages d'une conversation
final messagesProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, conversationId) {
  return ref.watch(getMessagesUsecaseProvider).call(conversationId);
});
