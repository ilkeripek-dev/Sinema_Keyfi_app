import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Link açmak için gerekli
import '../models/movie_model.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  var box = Hive.box<Movie>('favorites');
  bool isFavorite = false;
  
  late Future<List<String>> futureCast;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    isFavorite = box.containsKey(widget.movie.id);
    futureCast = apiService.getCast(widget.movie.id);
  }

  void _toggleFavorite() {
    setState(() {
      if (isFavorite) {
        box.delete(widget.movie.id);
        isFavorite = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favorilerden çıkarıldı 💔"), duration: Duration(seconds: 1)),
        );
      } else {
        box.put(widget.movie.id, widget.movie);
        isFavorite = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favorilere eklendi ❤️"), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  // Fragman butonuna basınca çalışacak fonksiyon
  void _launchTrailer() async {
    // 1. Yükleniyor göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fragman aranıyor... 🎬"), duration: Duration(milliseconds: 1500)),
    );

    // 2. Servisten fragman kodunu al
    final String? videoKey = await apiService.getYoutubeTrailerKey(widget.movie.id);

    if (videoKey != null) {
      // 3. YouTube linkini oluştur
      final Uri url = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
      
      // 4. Linki aç (Dış uygulamada açmayı dener)
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fragman açılamadı ")),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu filmin fragmanı bulunamadı. 🤷‍♂️")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";
    final fullPosterUrl = "$imageBaseUrl${widget.movie.posterPath}";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
                size: 30,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÜST KISIM: Büyük Resim
            Stack(
              children: [
                widget.movie.posterPath != null
                    ? CachedNetworkImage(
                        imageUrl: fullPosterUrl,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 400, 
                        color: Colors.grey, 
                        child: const Icon(Icons.movie, size: 100)
                      ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF121212)],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. ALT KISIM: Bilgiler
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Puan Kısmı
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 5),
                          Text(
                            "${widget.movie.voteAverage.toStringAsFixed(1)} / 10",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      // --- FRAGMAN BUTONU (YENİ) ---
                      ElevatedButton.icon(
                        onPressed: _launchTrailer,
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                        label: Text(
                          "Fragmanı İzle", 
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Özet",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.movie.overview.isEmpty 
                        ? "Bu film için henüz Türkçe özet eklenmemiş." 
                        : widget.movie.overview,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white70,
                      fontStyle: widget.movie.overview.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Oyuncular",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<String>>(
                    future: futureCast,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Yükleniyor...", style: TextStyle(color: Colors.grey));
                      } else if (snapshot.hasError) {
                        return const Text("Oyuncu bilgisi alınamadı.", style: TextStyle(color: Colors.grey));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Oyuncu bilgisi yok.", style: TextStyle(color: Colors.grey));
                      }

                      final actors = snapshot.data!;

                      return SizedBox(
                        height: 50, 
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, 
                          itemCount: actors.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2C), 
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Center(
                                child: Text(
                                  actors[index],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}