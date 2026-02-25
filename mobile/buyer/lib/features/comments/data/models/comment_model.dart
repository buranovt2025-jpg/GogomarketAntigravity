class CommentModel {
  final String id;
  final String storyId;
  final String userId;
  final UserInfo user;
  final String content;
  final String? parentId;
  final int likesCount;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.user,
    required this.content,
    this.parentId,
    required this.likesCount,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      storyId: json['storyId'],
      userId: json['userId'],
      user: UserInfo.fromJson(json['user'] ?? {}),
      content: json['content'],
      parentId: json['parentId'],
      likesCount: json['likesCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class UserInfo {
  final String id;
  final String phone;

  UserInfo({
    required this.id,
    required this.phone,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
