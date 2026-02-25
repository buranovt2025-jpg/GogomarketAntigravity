class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String role;
  final bool isVerified;
  final bool isBlocked;
  final SellerProfileModel? sellerProfile;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.role,
    required this.isVerified,
    required this.isBlocked,
    this.sellerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      isVerified: json['isVerified'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      sellerProfile: json['sellerProfile'] != null
          ? SellerProfileModel.fromJson(json['sellerProfile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'sellerProfile': sellerProfile?.toJson(),
    };
  }
}

class SellerProfileModel {
  final String id;
  final String userId;
  final String cabinetType;
  final String storeName;
  final String? description;
  final String? logoUrl;
  final String? category;
  final double rating;
  final int totalReviews;
  final bool isOnline;
  final String verificationStatus;
  final double balance;
  final double totalSales;
  final int followersCount;

  SellerProfileModel({
    required this.id,
    required this.userId,
    required this.cabinetType,
    required this.storeName,
    this.description,
    this.logoUrl,
    this.category,
    required this.rating,
    required this.totalReviews,
    required this.isOnline,
    required this.verificationStatus,
    required this.balance,
    required this.totalSales,
    required this.followersCount,
  });

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileModel(
      id: json['id'],
      userId: json['userId'],
      cabinetType: json['cabinetType'],
      storeName: json['storeName'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      category: json['category'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      balance: (json['balance'] ?? 0).toDouble(),
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      followersCount: json['followersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'cabinetType': cabinetType,
      'storeName': storeName,
      'description': description,
      'logoUrl': logoUrl,
      'category': category,
      'rating': rating,
      'totalReviews': totalReviews,
      'isOnline': isOnline,
      'verificationStatus': verificationStatus,
      'balance': balance,
      'totalSales': totalSales,
      'followersCount': followersCount,
    };
  }
}
