import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/datasources/local/cache_service.dart';

void main() async {
  // Ensure widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline caching
  await CacheService.init();
  
  // Load environment variables (non-blocking for first frame)
  // Using a deferred approach to avoid blocking the first frame
  unawaited(dotenv.load(fileName: ".env"));
  
  // Initialize caches (non-blocking)
  unawaited(CacheService.init());
  
  // Disable physical animations for consistent performance testing
  // Comment this out for production
  // debugEnablePhysicalAnimations = false;
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Helper to fire-and-forget async operations without await
// This prevents blocking the first frame
void unawaited(Future<void> future) {
  future.catchError((_) {});
}
