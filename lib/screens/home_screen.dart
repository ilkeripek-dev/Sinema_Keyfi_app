import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/movie_model.dart';
import 'detail_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  
  // --- YENİ DEĞİŞKENLER ---
  List<Movie> movies = []; // Tüm filmleri burada tutacağız
  int currentPage = 1;     // Şu anki sayfa numarası
  bool isLoading = false;  // Şu an veri çekiliyor mu?
  final ScrollController _scrollController = ScrollController(); // Kaydırmayı takip eden ajan
  
  int selectedCategoryId = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': '🔥 Popüler', 'id': 0},
    {'name': '😂 Komedi', 'id': 35},
    {'name': '💥 Aksiyon', 'id': 28},
    {'name': '😱 Gerilim', 'id': 53},
    {'name': '❤️ Duygusal', 'id': 10749},
    {'name': '🚀 Bilim Kurgu', 'id': 878},
    {'name': '👶 Animasyon', 'id': 16},
  ];

  @override
  void initState() {
    super.initState();
    // İlk açılışta verileri çek
    _fetchMovies();

    // Kaydırma (Scroll) Dinleyicisi
    _scrollController.addListener(() {
      // Eğer listenin sonuna geldiysek ve şu an yükleme yapmıyorsak
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !isLoading) {
        // Bir sonraki sayfayı yükle
        _fetchMovies();
      }
    });
  }

  // Filmleri Çeken Fonksiyon
  Future<void> _fetchMovies() async {
    if (isLoading) return; // Zaten yüklüyorsa tekrar yükleme

    setState(() {
      isLoading = true; // Yükleniyor işaretini aç
    });

    try {
      List<Movie> newMovies;

      if (selectedCategoryId == 0) {
        // Popüler filmlerden sıradaki sayfayı getir
        newMovies = await apiService.getPopularMovies(page: currentPage);
      } else {
        // Kategori filmlerinden sıradaki sayfayı getir
        newMovies = await apiService.getMoviesByGenre(selectedCategoryId, page: currentPage);
      }

      setState(() {
        movies.addAll(newMovies); // Yeni gelenleri listenin ucuna ekle
        currentPage++; // Sayfa numarasını bir arttır
        isLoading = false; // Yükleme bitti
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Hata olursa kullanıcıya bildir (Opsiyonel)
      print("Hata oluştu: $e");
    }
  }

  // Kategori Değişince Çalışacak Fonksiyon
  void _onCategorySelected(int id) {
    if (selectedCategoryId == id) return; // Aynı kategoriye basarsa işlem yapma

    setState(() {
      selectedCategoryId = id;
      movies.clear(); // Eski listeyi temizle
      currentPage = 1; // Sayfayı başa sar
    });
    
    // Yeni kategori için verileri çek
    _fetchMovies();
  }

  void _surpriseMe() async {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      ),
    );

    try {
      final movie = await apiService.getSurpriseMovie();
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(movie: movie)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şansına küs, bir hata oldu! 🎲")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Hafıza temizliği
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _surpriseMe,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.shuffle, color: Colors.white),
        label: Text(
          "Şaşırt Beni", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sinema Keyfi 🎬', // İsim güncellediğin gibi
          style: GoogleFonts.poppins(
            color: Colors.redAccent, 
            fontWeight: FontWeight.bold, 
            fontSize: 24
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              showSearch(context: context, delegate: MovieSearchDelegate());
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal, 
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category['id'] == selectedCategoryId;

                return GestureDetector(
                  onTap: () => _onCategorySelected(category['id']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.redAccent : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: Colors.redAccent, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        category['name'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: movies.isEmpty && isLoading
                // İlk açılışta yükleniyor göster
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : movies.isEmpty && !isLoading
                    // Veri yoksa mesaj göster
                    ? const Center(child: Text("Film bulunamadı", style: TextStyle(color: Colors.white)))
                    : GridView.builder(
                        controller: _scrollController, // Controller'ı bağladık!
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        // Eğer yükleniyorsa altta spinner göstermek için +1 eleman ekle
                        itemCount: movies.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Eğer son elemansa ve yükleniyorsa spinner göster
                          if (index == movies.length) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.redAccent),
                            );
                          }

                          final movie = movies[index];
                          final posterUrl = "${apiService.imageBaseUrl}${movie.posterPath}";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(movie: movie),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 3))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    movie.posterPath != null
                                        ? CachedNetworkImage(
                                            imageUrl: posterUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(color: Colors.grey[900]),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          )
                                        : Container(color: Colors.grey, child: const Icon(Icons.movie)),

                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [Colors.black, Colors.transparent],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white, 
                                                fontWeight: FontWeight.bold, 
                                                fontSize: 14
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, size: 12, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              movie.voteAverage.toStringAsFixed(1),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}