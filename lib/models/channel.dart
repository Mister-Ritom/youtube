class Channel {
  final String id;
  final String username;
  final String displayName;
  final String profileImage;
  final String description;
  final String banner;
  final int totalViews;
  final int videoCount;

  Channel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.description,
    this.profileImage='assets/ProfileImage.png',
    this.banner = '',
    this.totalViews = 0,
    this.videoCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'profileImage': profileImage,
      'banner': banner,
      'totalViews': totalViews,
      'videoCount' : videoCount,
      'description': description,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      profileImage: json['profileImage'],
      banner: json['banner'],
      totalViews: json['totalViews'],
      videoCount: json['videoCount'],
      description: json['description'],
    );
  }
}
