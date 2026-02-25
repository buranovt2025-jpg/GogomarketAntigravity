import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/story_model.dart';
import '../../providers/stories_provider.dart';
import '../../../comments/presentation/widgets/comments_bottom_sheet.dart';

class StoryPlayer extends ConsumerStatefulWidget {
  final StoryModel story;
  final bool isActive;

  const StoryPlayer({
    super.key,
    required this.story,
    required this.isActive,
  });

  @override
  ConsumerState<StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends ConsumerState<StoryPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  int _watchStartTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(StoryPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _controller?.play();
      _watchStartTime = DateTime.now().millisecondsSinceEpoch;
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
      _recordView();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.story.videoUrl));
    
    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
      
      if (widget.isActive) {
        _controller!.play();
        _controller!.setLooping(true);
        _watchStartTime = DateTime.now().millisecondsSinceEpoch;
      }
    } catch (e) {
      // Handle video load error
      debugPrint('Video init error: $e');
    }
  }

  void _recordView() {
    if (_watchStartTime > 0) {
      final watchDuration = (DateTime.now().millisecondsSinceEpoch - _watchStartTime) ~/ 1000;
      if (watchDuration > 0) {
        ref.read(storiesProvider.notifier).recordView(widget.story.id, watchDuration);
      }
    }
  }

  void _toggleLike() {
    ref.read(storiesProvider.notifier).toggleLike(widget.story.id);
  }

  @override
  void dispose() {
    _recordView();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        if (_isInitialized && _controller != null)
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              _ActionButton(
                icon: widget.story.isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(widget.story.likesCount),
                onTap: _toggleLike,
                color: widget.story.isLiked ? Colors.red : Colors.white,
              ),
              const SizedBox(height: 24),

              // Views
              _ActionButton(
                icon: Icons.remove_red_eye,
                label: _formatCount(widget.story.viewsCount),
                onTap: null,
              ),
              const SizedBox(height: 24),

              // Comments
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comment',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsBottomSheet(storyId: widget.story.id),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Product (if linked)
              if (widget.story.product != null)
                _ActionButton(
                  icon: Icons.shopping_bag,
                  label: 'Shop',
                  onTap: () {
                    // Navigate to product
                  },
                ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 16,
          right: 80,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seller info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      widget.story.seller.businessName?.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.seller.businessName ?? widget.story.seller.phone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _getTimeAgo(widget.story.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (widget.story.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.story.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Product info
              if (widget.story.product != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (widget.story.product!.images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            widget.story.product!.images[0],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.story.product!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${widget.story.product!.price.toStringAsFixed(0)} UZS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
