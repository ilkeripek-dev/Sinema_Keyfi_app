import 'package:hive/hive.dart';

// Bu satır birazdan otomatik oluşacak dosyanın adıdır.
// Şu an kırmızı yanabilir, görmezden gel.
part 'movie_model.g.dart';

@HiveType(typeId: 1) // Bu kutunun kimlik numarası 1 olsun
class Movie {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final String overview;

  @HiveField(4)
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.overview,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'İsimsiz Film',
      posterPath: json['poster_path'],
      overview: json['overview'] ?? 'Özet bulunamadı.',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}