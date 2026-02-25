import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/stories_service.dart';
import '../data/models/story_model.dart';

final storiesFeedProvider = FutureProvider<List<StoryModel>>((ref) async {
  final storiesService = ref.watch(storiesServiceProvider);
  return storiesService.getFeed();
});

class StoriesNotifier extends StateNotifier<List<StoryModel>> {
  final StoriesService _storiesService;

  StoriesNotifier(this._storiesService) : super([]);

  Future<void> loadFeed() async {
    try {
      final stories = await _storiesService.getFeed();
      state = stories;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> toggleLike(String storyId) async {
    try {
      final result = await _storiesService.toggleLike(storyId);
      final liked = result['liked'] as bool;

      // Update local state
      state = [
        for (final story in state)
          if (story.id == storyId)
            story.copyWith(
              isLiked: liked,
              likesCount: liked ? story.likesCount + 1 : story.likesCount - 1,
            )
          else
            story,
      ];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  Future<void> recordView(String storyId, int watchDuration) async {
    try {
      await _storiesService.recordView(storyId, watchDuration);
    } catch (e) {
      // Ignore view tracking errors
    }
  }
}

final storiesProvider = StateNotifierProvider<StoriesNotifier, List<StoryModel>>((ref) {
  final storiesService = ref.watch(storiesServiceProvider);
  return StoriesNotifier(storiesService);
});
