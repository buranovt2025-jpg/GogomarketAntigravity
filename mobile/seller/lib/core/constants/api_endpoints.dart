class ApiEndpoints {
  // Base URL - change for production
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String getProfile = '/auth/me';

  // Products endpoints
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String myProducts = '/products/seller/my-products';
  static const String searchProducts = '/products/search';

  // Media endpoints
  static const String uploadImage = '/media/upload/image';
  static const String uploadVideo = '/media/upload/video';
  static const String deleteMedia = '/media';

  // Users endpoints
  static const String userProfile = '/users/profile';
  static String sellerProfile(String id) => '/users/sellers/$id';
}
