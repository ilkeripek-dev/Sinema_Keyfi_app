import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  // 👇 BURAYA KENDİ API KEY'İNİ MUTLAKA TEKRAR YAPIŞTIR
  final String apiKey = "d724a5d75373b6467a7507e7c830caba"; 
  
  final String baseUrl = "https://api.themoviedb.org/3";
  final String imageBaseUrl = "https://image.tmdb.org/t/p/w500"; 

  // 1. Popüler Filmleri Getir (Sayfa Destekli)
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    // URL'in sonuna &page=$page ekledik
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=tr-TR&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List results = decodedData['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Filmler yüklenemedi!');
    }
  }

  // 2. Film Ara
  Future<List<Movie>> searchMovies(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$baseUrl/search/movie?api_key=$apiKey&language=tr-TR&query=$encodedQuery');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List results = decodedData['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Arama yapılamadı!');
    }
  }

  // 3. Kategoriye Göre Film Getir (Sayfa Destekli)
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    // URL'in sonuna &page=$page ekledik
    final url = Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&language=tr-TR&with_genres=$genreId&sort_by=popularity.desc&page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List results = decodedData['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Kategori filmleri yüklenemedi!');
    }
  }

  // 4. Şaşırt Beni (Rastgele Film)
  Future<Movie> getSurpriseMovie() async {
    int randomPage = Random().nextInt(50) + 1;
    final url = Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&language=tr-TR&page=$randomPage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List results = decodedData['results'];
      if (results.isNotEmpty) {
        int randomIndex = Random().nextInt(results.length);
        return Movie.fromJson(results[randomIndex]);
      } else {
        throw Exception('Bu sayfada film yokmuş.');
      }
    } else {
      throw Exception('Şansına küs, film bulunamadı!');
    }
  }

  // 5. Oyuncuları Getir
  Future<List<String>> getCast(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey&language=tr-TR');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List castList = decodedData['cast'];
      List<String> actorNames = castList.take(10).map((actor) {
        return actor['name'].toString();
      }).toList();
      return actorNames;
    } else {
      return [];
    }
  }

  // 6. Fragman Anahtarını Bul
  Future<String?> getYoutubeTrailerKey(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=tr-TR');
    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      var results = decodedData['results'] as List;
      
      if (results.isEmpty) {
         final urlEn = Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US');
         response = await http.get(urlEn);
         decodedData = json.decode(response.body);
         results = decodedData['results'] as List;
      }

      for (var video in results) {
        if (video['site'] == 'YouTube' && video['type'] == 'Trailer') {
          return video['key'];
        }
      }
    }
    return null;
  }
}