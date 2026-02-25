import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../models/comment_model.dart';

final commentsServiceProvider = Provider<CommentsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommentsService(apiClient);
});

class CommentsService {
  final ApiClient _apiClient;

  CommentsService(this._apiClient);

  Future<List<CommentModel>> getComments(String storyId) async {
    final response = await _apiClient.get('/comments/story/$storyId');
    final List<dynamic> data = response.data;
    return data.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<CommentModel> createComment(String storyId, String content, {String? parentId}) async {
    final response = await _apiClient.post(
      '/comments',
      data: {
        'storyId': storyId,
        'content': content,
        if (parentId != null) 'parentId': parentId,
      },
    );
    return CommentModel.fromJson(response.data);
  }

  Future<void> deleteComment(String commentId) async {
    await _apiClient.delete('/comments/$commentId');
  }

  Future<int> getCommentsCount(String storyId) async {
    final response = await _apiClient.get('/comments/story/$storyId/count');
    return response.data['count'];
  }
}
