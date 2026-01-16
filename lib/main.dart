import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/movie_model.dart'; // Movie modelimizi ve Adapter'ı buradan alacak
import 'screens/home_screen.dart';

void main() async {
  // 1. Flutter motorunu hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive veritabanını başlat
  await Hive.initFlutter();

  // 3. Film adaptörünü kaydet (Hive artık Movie'yi tanıyor)
  // Eğer bu satırda hata alırsan: terminalde "dart run build_runner build" yaptığından emin ol.
  Hive.registerAdapter(MovieAdapter());

  // 4. Favoriler kutusunu aç
  await Hive.openBox<Movie>('favorites');

  runApp(const FilmRehberiApp());
}

class FilmRehberiApp extends StatelessWidget {
  const FilmRehberiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Film Rehberi',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.orangeAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}