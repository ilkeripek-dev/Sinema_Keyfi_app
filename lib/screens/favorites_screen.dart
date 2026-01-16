import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hive kutusunu çağırıyoruz
    final box = Hive.box<Movie>('favorites');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Favorilerim ❤️",
          style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Geri tuşu beyaz olsun
      ),
      // Kutuyu dinleyen yapı. Kutuya ekleme/çıkarma olursa anında ekranı yeniler.
      body: ValueListenableBuilder<Box<Movie>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          // Filmleri listeye çevir
          final movies = box.values.toList().cast<Movie>();

          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    "Henüz favori filmin yok.",
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              // Resim URL'si (İnternet yoksa placeholder göstereceğiz ama kod yine de url ister)
              const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";
              final posterUrl = "$imageBaseUrl${movie.posterPath}";

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailScreen(movie: movie)),
                    );
                  },
                  // Sol tarafta resim
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: movie.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[800]),
                            errorWidget: (context, url, error) => const Icon(Icons.movie, color: Colors.white),
                          )
                        : const Icon(Icons.movie, size: 60, color: Colors.white),
                  ),
                  // Film Başlığı
                  title: Text(
                    movie.title,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  // Puanı
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  // Sağ tarafta silme butonu
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      // Kutudan sil
                      box.delete(movie.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}