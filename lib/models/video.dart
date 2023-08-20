enum VideoPrivacy {
  public,
  private,
  linkOnly
}

class Video {
  final String id;
  final String title;
  final String description;
  final VideoPrivacy privacy;
  final String thumbnail;
  final int views;
  final int likes;
  final int dislikes;
  final int comments;
  final String ownerId;
  final int uploadTime;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.privacy,
    required this.ownerId,
    required this.uploadTime,
    this.views = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'privacy': privacy.toString(),
      'thumbnail': thumbnail,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'comments': comments,
      'ownerId': ownerId,
      "uploadTime": uploadTime,
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      privacy: _parsePrivacy(json['privacy']),
      thumbnail: json['thumbnail'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      comments: json['comments'] ?? 0,
      ownerId: json['ownerId'],
      uploadTime: json["uploadTime"],
    );
  }

  static VideoPrivacy _parsePrivacy(String privacy) {
    switch (privacy) {
      case 'VideoPrivacy.public':
        return VideoPrivacy.public;
      case 'VideoPrivacy.private':
        return VideoPrivacy.private;
      case 'VideoPrivacy.linkOnly':
        return VideoPrivacy.linkOnly;
      default:
        throw ArgumentError("Invalid VideoPrivacy value: $privacy");
    }
  }
}
