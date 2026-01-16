import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class MovieSearchDelegate extends SearchDelegate {
  final ApiService apiService = ApiService();

  // Arama barının sağındaki ikonlar (Çarpı tuşu temizlemek için)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Yazıyı temizle
        },
      ),
    ];
  }

  // Arama barının solundaki ikon (Geri tuşu)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Aramayı kapat
      },
    );
  }

  // Arama tuşuna basınca veya yazarken sonuçları göster
  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 2) {
      return const Center(child: Text("Aramak için en az 2 harf yazın."));
    }

    return FutureBuilder<List<Movie>>(
      future: apiService.searchMovies(query), // Servisteki yeni fonksiyonu kullanıyoruz
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
        } else if (snapshot.hasError) {
          return const Center(child: Text("Bir hata oluştu."));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Film bulunamadı."));
        }

        final movies = snapshot.data!;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            final posterUrl = "${apiService.imageBaseUrl}${movie.posterPath}";

            return ListTile(
              onTap: () {
                // Listeden tıklayınca da detaya gitsin
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(movie: movie),
                    ),
                  );
              },
              leading: movie.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: posterUrl,
                      width: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Icon(Icons.movie),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : const Icon(Icons.movie, size: 50),
              title: Text(movie.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text(
                movie.voteAverage > 0 ? "⭐ ${movie.voteAverage}" : "Puan yok",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }

  // Kullanıcı yazarken öneri gösterme kısmı (Biz direkt sonuç gösteriyoruz, o yüzden aynısı)
  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context); // Yazarken anlık arama yapsın
  }
  
  // Arama sayfasının tema ayarları (Karanlık mod uyumu için)
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E), // Koyu gri AppBar
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18), // Yazılan yazı rengi
      ),
    );
  }
}