import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../models/story_model.dart';

final storiesServiceProvider = Provider<StoriesService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoriesService(apiClient);
});

class StoriesService {
  final ApiClient _apiClient;

  StoriesService(this._apiClient);

  Future<List<StoryModel>> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _apiClient.get(
      '/stories/feed',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    final List<dynamic> data = response.data;
    return data.map((json) => StoryModel.fromJson(json)).toList();
  }

  Future<void> recordView(String storyId, int watchDuration) async {
    await _apiClient.post(
      '/stories/$storyId/view',
      data: {'watchDuration': watchDuration},
    );
  }

  Future<Map<String, dynamic>> toggleLike(String storyId) async {
    final response = await _apiClient.post('/stories/$storyId/like');
    return response.data;
  }
}
