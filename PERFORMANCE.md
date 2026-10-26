# Performance Optimization Guide

## Target Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Frame Rate | 60 FPS (minimum), 120 FPS (capable devices) | DevTools Timeline |
| Frame Time | ≤16.67ms (60fps), ≤8.33ms (120fps) | DevTools Performance Overlay |
| Cold Start Time | <2 seconds | `flutter run --profile` |
| Jank | 0 dropped frames | DevTools Performance |
| Memory Usage | <200MB typical, <500MB max | DevTools Memory |

## Performance Changes Made

### 1. Widget Tree Optimization

#### Fixed Issues:
- **Replaced Column+SingleChildScrollView with ListView.builder** for article feeds
- **Added const constructors** to all stateless widgets where possible
- **Added explicit keys** to all ListView items, AnimatedWidgets, and Form widgets
- **Split oversized build() methods** into smaller widget compositions
- **Added RepaintBoundary** around expensive subtrees (article cards, images)
- **Used IndexedStack** instead of Column for tab-like switching

#### Files Modified:
- `lib/presentation/pages/home/home_page.dart` - ListView.builder for feeds
- `lib/presentation/widgets/article/article_card.dart` - Added RepaintBoundary, const constructors
- `lib/presentation/widgets/common/app_*.dart` - Added const constructors
- `lib/presentation/pages/article/article_detail_page.dart` - Optimized nested widgets

### 2. Image Loading Optimization

#### Applied:
- **cached_network_image** for all remote images with proper caching
- **Placeholder and error widgets** to prevent layout shifts
- **Fade-in animation** for smooth image loading
- **Image compression** before upload (80% quality)
- **Appropriate image sizes** (max 1200px width for covers)

#### Files Modified:
- `lib/presentation/widgets/article/article_card.dart` - Wrapped images in CachedNetworkImage
- `lib/presentation/pages/article/article_detail_page.dart` - Optimized cover image loading

### 3. State Management Optimization

#### Applied:
- **Proper Riverpod provider scoping** to prevent unnecessary rebuilds
- **AsyncValue handling** with loading/error states
- **Debounced search** and input handlers
- **Memoization** for expensive computations (read time, excerpt generation)

#### Files Modified:
- `lib/presentation/providers/article_provider.dart` - Optimized state updates
- `lib/presentation/providers/auth_provider.dart` - Proper async handling
- `lib/presentation/providers/comment_provider.dart` - Pagination optimization

### 4. Supabase Initialization Optimization

#### Applied:
- **Lazy initialization** of Supabase client
- **Deferred loading** of non-critical data
- **Connection pooling** and reuse
- **Offline-first** with local caching

#### Files Modified:
- `lib/data/datasources/remote/supabase_client.dart` - Lazy initialization
- `lib/main.dart` - Deferred Supabase init

### 5. List Rendering Optimization

#### Applied:
- **ListView.builder** for all scrollable lists
- **Item extent** for fixed-height items
- **Pagination** with proper batch sizes (20 items)
- **Pre-fetching** for smooth scrolling
- **Diffing** for list updates (using keys)

#### Files Modified:
- `lib/presentation/pages/home/home_page.dart` - ListView.builder with item extent
- `lib/presentation/widgets/comment/comment_section.dart` - Optimized comment list

### 6. Navigation Optimization

#### Applied:
- **GoRouter** with proper route caching
- **Hero animations** for smooth transitions
- **Pre-loaded pages** for critical routes
- **Lazy loading** of non-critical pages

### 7. Memory Optimization

#### Applied:
- **Weak references** where appropriate
- **Proper disposal** of controllers and streams
- **Image caching** with size limits
- **Garbage collection hints** for large data

## Performance Profiling

### Using DevTools

1. **Run with profiling enabled:**
   ```bash
   flutter run --profile
   ```

2. **Enable performance overlay:**
   ```dart
   MaterialApp(
     debugShowCheckedModeBanner: false,
     showPerformanceOverlay: true, // Add this
   )
   ```

3. **Use DevTools:**
   - Open DevTools from your IDE or browser
   - Navigate to the **Performance** tab
   - Click **Record** and interact with your app
   - Look for:
     - Long frame times (>16ms)
     - Dropped frames
     - UI jank
     - Memory spikes

### Using Timeline

1. **Record a timeline:**
   ```bash
   flutter run --profile
   ```
   Then in DevTools:
   - Go to **Timeline** tab
   - Click **Record**
   - Perform actions in your app
   - Stop recording and analyze

2. **Look for:**
   - Long **Build** phases (widget construction)
   - Long **Layout** phases
   - Long **Paint** phases
   - **Raster** threads blocking

### Using Memory View

1. **Check memory usage:**
   - Go to **Memory** tab in DevTools
   - Take snapshots before/after actions
   - Look for memory leaks

2. **Monitor:**
   - Dart heap usage
   - Native memory usage
   - Garbage collection frequency

## Common Performance Pitfalls (Fixed)

### ❌ Bad: Column with many children
```dart
Column(
  children: articles.map((a) => ArticleCard(article: a)).toList(),
)
```
**Problem:** All widgets built at once, even off-screen

### ✅ Good: ListView.builder
```dart
ListView.builder(
  itemCount: articles.length,
  itemBuilder: (context, index) => ArticleCard(article: articles[index]),
)
```
**Solution:** Only builds visible widgets

---

### ❌ Bad: Missing keys in lists
```dart
ListView.builder(
  itemBuilder: (context, index) => ArticleCard(article: articles[index]),
)
```
**Problem:** Flutter can't efficiently update list items

### ✅ Good: With keys
```dart
ListView.builder(
  itemBuilder: (context, index) => ArticleCard(
    key: ValueKey(articles[index].id),
    article: articles[index],
  ),
)
```
**Solution:** Flutter can reuse widgets efficiently

---

### ❌ Bad: Non-const widgets
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello'),
    );
  }
}
```
**Problem:** Rebuilds unnecessarily

### ✅ Good: Const constructors
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Container(
      child: Text('Hello'),
    );
  }
}
```
**Solution:** Prevents unnecessary rebuilds

---

### ❌ Bad: Large build methods
```dart
@override
Widget build(BuildContext context) {
  // 200+ lines of widget tree
  return Column(
    children: [
      // ... 50+ widgets
    ],
  );
}
```
**Problem:** Hard to optimize, rebuilds entire tree

### ✅ Good: Split into smaller widgets
```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const Header(),
      const Content(),
      const Footer(),
    ],
  );
}

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return // Header widgets
  }
}
```
**Solution:** Better caching, easier optimization

---

### ❌ Bad: Direct image loading
```dart
Image.network('https://example.com/image.jpg')
```
**Problem:** No caching, no placeholder, causes jank

### ✅ Good: Cached with placeholder
```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInImage: true,
  fadeInDuration: const Duration(milliseconds: 300),
)
```
**Solution:** Smooth loading, caching, error handling

---

### ❌ Bad: Blocking initialization
```dart
void main() async {
  await Supabase.initialize(); // Blocks first frame
  runApp(MyApp());
}
```
**Problem:** Delays first frame render

### ✅ Good: Deferred initialization
```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Supabase.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(home: HomePage());
        }
        return const LoadingScreen(); // Show loading while initializing
      },
    );
  }
}
```
**Solution:** First frame renders immediately

## Performance Checklist

- [x] All lists use `ListView.builder` or `ListView.separated`
- [x] All list items have explicit `key` properties
- [x] All stateless widgets have `const` constructors where possible
- [x] All remote images use `CachedNetworkImage`
- [x] Supabase initialization is deferred
- [x] Expensive widgets wrapped in `RepaintBoundary`
- [x] Large build methods split into smaller widgets
- [x] Proper disposal of controllers and streams
- [x] Loading states for async operations
- [x] Error handling for all async operations

## Frame Budget Analysis

| Device | Refresh Rate | Frame Budget | Target |
|--------|--------------|--------------|--------|
| Most phones | 60Hz | 16.67ms | ≤16ms |
| High-end phones | 90Hz | 11.11ms | ≤10ms |
| High-end phones | 120Hz | 8.33ms | ≤8ms |

### Frame Time Breakdown (Target)
- **Build:** ≤5ms
- **Layout:** ≤3ms
- **Paint:** ≤3ms
- **Raster:** ≤5ms
- **Total:** ≤16ms

## Optimization Techniques Applied

### 1. Widget Caching
- Use `const` constructors for stateless widgets
- Use `AutomaticKeepAliveClientMixin` for tab pages
- Cache expensive widget subtree results

### 2. Image Optimization
- Use `CachedNetworkImage` with memory and disk caching
- Compress images before upload (80% quality)
- Use appropriate image sizes (max 1200px for covers)
- Implement placeholder and error widgets

### 3. List Optimization
- Use `ListView.builder` for all scrollable lists
- Specify `itemExtent` for fixed-height items
- Implement pagination with proper batch sizes
- Use keys for efficient diffing

### 4. State Management
- Use Riverpod for efficient state updates
- Scope providers to minimize rebuilds
- Use `AsyncValue` for loading/error states
- Debounce rapid state changes

### 5. Network Optimization
- Batch API requests where possible
- Implement request deduplication
- Use caching for frequent requests
- Compress request/response data

### 6. Memory Management
- Dispose controllers and streams properly
- Use weak references where appropriate
- Implement image caching with size limits
- Monitor memory usage with DevTools

## Profiling Commands

### Basic Profiling
```bash
flutter run --profile
```

### Performance Overlay
```bash
flutter run --profile --show-performance-overlay
```

### Timeline Recording
```bash
flutter run --profile
# Then in DevTools: Timeline -> Record
```

### Memory Profiling
```bash
flutter run --profile
# Then in DevTools: Memory -> Take Snapshot
```

### CPU Profiling
```bash
flutter run --profile --cpu-profiler
# Then in DevTools: CPU Profiler -> Record
```

## Continuous Monitoring

Add this to your `main.dart` for production monitoring:

```dart
void main() {
  // Enable performance monitoring
  debugEnablePhysicalAnimations = false;
  
  runApp(const MyApp());
}
```

Use `flutter drive` for integration test performance:
```bash
flutter drive --profile integration_test/performance_test.dart
```

## References

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Rendering Performance](https://docs.flutter.dev/perf/rendering-perf)
- [Flutter Performance Profiling](https://flutter.dev/docs/perf/ui-performance)
