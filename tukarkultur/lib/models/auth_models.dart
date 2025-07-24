class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? profilePictureUrl;
  final String? bio;
  final int? age;
  final String? city;
  final String? country;
  final List<String> interests;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;
  final int totalInteractions;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.profilePictureUrl,
    this.bio,
    this.age,
    this.city,
    this.country,
    this.interests = const [],
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.totalInteractions = 0,
    this.averageRating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      bio: json['bio'],
      age: json['age'],
      city: json['city'],
      country: json['country'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : [],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationUpdatedAt: json['location_updated_at'] != null
          ? DateTime.parse(json['location_updated_at'])
          : null,
      totalInteractions: json['total_interactions'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (bio != null) 'bio': bio,
      if (age != null) 'age': age,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      'interests': interests,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationUpdatedAt != null) 'location_updated_at': locationUpdatedAt!.toIso8601String(),
      'total_interactions': totalInteractions,
      'average_rating': averageRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? bio;
  final int? age;
  final String? city;
  final String? country;
  final List<String> interests;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.bio,
    this.age,
    this.city,
    this.country,
    this.interests = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      if (bio != null) 'bio': bio,
      if (age != null) 'age': age,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      'interests': interests,
    };
  }
}

class AuthResponse {
  final String token;
  final User user;
  final String message;

  AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
      message: json['message'] ?? '',
    );
  }
}

class AuthError {
  final String error;
  final String? details;
  final int? code;

  AuthError({
    required this.error,
    this.details,
    this.code,
  });

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      error: json['error'] ?? 'Unknown error',
      details: json['details'],
      code: json['code'],
    );
  }

  @override
  String toString() {
    return details ?? error;
  }
}
