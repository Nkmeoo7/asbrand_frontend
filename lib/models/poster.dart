class Poster {
  final String id;
  final String posterName;
  final String imageUrl;

  Poster({
    required this.id,
    required this.posterName,
    required this.imageUrl,
  });

  factory Poster.fromJson(Map<String, dynamic> json) {
    return Poster(
      id: json['_id'] ?? '',
      posterName: json['posterName'] ?? '',
      imageUrl: json['imageUrl'] is Map ? (json['imageUrl']['path'] ?? json['imageUrl']['url']) : (json['imageUrl'] ?? ''),
    );
  }
}
