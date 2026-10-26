# Medium Clone - Flutter + Supabase

A production-ready Medium-style publishing and reading application built with Flutter and Dart, backed by Supabase.

## Features

### Core Features
- **Authentication**: Email/password, Google OAuth via Supabase Auth
- **Articles**: Create, read, update, delete with rich markdown editing
- **Claps**: Animated clap feature with particle effects
- **Bookmarks**: Save articles for later reading
- **Highlights**: Select and highlight text with custom colors
- **Tags**: Categorize articles with tags and discover by tags
- **Search**: Full-text search with filters
- **Feed**: Personalized feed algorithm (50% followed authors, 30% followed tags, 20% trending)
- **Trending**: Discover trending articles

### Advanced Features
- **Offline Support**: Hive-based caching for articles and user data
- **Drafts & Auto-save**: Automatic saving of drafts every minute
- **SEO**: Open Graph, Twitter Cards, and Schema.org meta tags
- **Social Sharing**: Share articles on Twitter, Facebook, LinkedIn, or copy link
- **Analytics Dashboard**: Writers can view their article performance
- **Custom Page Transitions**: Smooth shared-axis, fade, and slide transitions
- **Micro-interactions**: Scale animations on all interactive elements
- **Haptic Feedback**: Vibration feedback for claps and pull-to-refresh
- **Skeleton Loaders**: Shimmer effects for all loading states
- **Theme Customization**: Adjust font size, font family, and line height

### Performance
- **60 FPS minimum**, 120 FPS on capable devices
- Zero jank, zero dropped frames
- Fast flicker-free startup
- Optimized widget tree with `ListView.builder`, `RepaintBoundary`, `CachedNetworkImage`
- Lazy Supabase initialization
- All code passes `flutter analyze`

## Architecture

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/           # App configuration
│   ├── errors/              # Custom exceptions
│   ├── theme/               # Theme and styling
│   └── utils/               # Helper functions
├── data/                    # Data layer
│   ├── datasources/         # Remote and local data sources
│   ├── models/              # Data models
│   └── repositories/        # Repository implementations
└── presentation/            # Presentation layer
    ├── pages/               # App pages
    ├── providers/           # Riverpod providers
    ├── routes/              # Navigation routes
    └── widgets/             # Reusable widgets
```

## Getting Started

### Prerequisites
- Flutter SDK 3.19.5 or later
- Dart 3.3.0 or later
- Node.js (for Supabase CLI)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/bano-qabil123/Medium.git
cd Medium
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Create a `.env` file:
```bash
cp .env.example .env
```
   - Edit `.env` with your Supabase credentials:
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

4. **Setup Supabase Database**
   - Apply migrations:
```bash
# Install Supabase CLI
npm install -g supabase

# Link your project (requires supabase login)
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push --db-password your-db-password
```
   - Or use the Supabase Dashboard to run the SQL from `supabase/migrations/`

5. **Run the app**
```bash
flutter run
```

## Supabase Setup

### Required Tables
The app requires the following tables (included in migrations):
- `profiles` - User profiles
- `articles` - Articles
- `claps` - User claps on articles
- `bookmarks` - User bookmarks
- `highlights` - Text highlights
- `tags` - Article tags
- `article_tags` - Article-tag relationships
- `user_followed_tags` - User followed tags
- `article_views` - Article view tracking
- `comments` - Article comments
- `user_follows` - User follow relationships
- `drafts` - Auto-saved drafts

### Row Level Security (RLS)
All tables have RLS policies enabled for security. See `supabase/migrations/002_rls_policies.sql` for details.

## Project Structure

### Core Layer
- `app_constants.dart` - App-wide constants
- `app_theme.dart` - Theme configuration with Merriweather + Inter fonts
- `app_transitions.dart` - Custom page transitions
- `validators.dart` - Input validation helpers
- `helpers.dart` - Utility functions
- `exceptions.dart` - Custom exception classes

### Data Layer
- **Models**: User, Article, Clap, Bookmark, Highlight, Tag, etc.
- **Repositories**: Auth, Article, Clap, Bookmark, Highlight, Tag, etc.
- **Data Sources**: Supabase client with lazy initialization, Hive caching

### Presentation Layer
- **Pages**: Home, Article Detail, Editor, Profile, Settings, Search, Feed, Analytics, etc.
- **Providers**: Riverpod state management for all features
- **Widgets**: Reusable components (cards, buttons, loaders, etc.)
- **Routes**: GoRouter for declarative navigation

## Performance Optimizations

See [PERFORMANCE.md](PERFORMANCE.md) for detailed performance metrics and profiling instructions.

Key optimizations:
- Lazy Supabase initialization
- `ListView.builder` for all scrollable lists
- `RepaintBoundary` around expensive widgets
- `CachedNetworkImage` for remote images
- Const constructors where possible
- Explicit keys for list items and animated widgets
- Shimmer skeleton loaders
- Deferred loading of non-critical data

## CI/CD

GitHub Actions workflows are configured for:
- **Build**: Android APK, App Bundle, iOS, Linux, Web
- **Test**: Flutter analyze, unit tests, widget tests
- **Deploy**: GitHub Pages, Firebase App Distribution, TestFlight
- **Supabase**: Migration deployment

See `.github/workflows/` for details.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase publishable key | Yes |
| `SUPABASE_SERVICE_KEY` | Supabase service role key | No |
| `APP_NAME` | Application name | No |
| `APP_VERSION` | Application version | No |
| `ENVIRONMENT` | Environment (development, production) | No |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `flutter analyze` and fix all issues
5. Run `flutter test` to ensure tests pass
6. Commit and push your changes
7. Open a pull request

## License

MIT License

## Acknowledgments

- [Flutter](https://flutter.dev) - UI toolkit
- [Supabase](https://supabase.com) - Backend services
- [Riverpod](https://riverpod.dev) - State management
- [GoRouter](https://gorouter.dev) - Navigation
- [flutter_quill](https://pub.dev/packages/flutter_quill) - Markdown editing
- [flutter_markdown](https://pub.dev/packages/flutter_markdown) - Markdown rendering
- [cached_network_image](https://pub.dev/packages/cached_network_image) - Image caching
