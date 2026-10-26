import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medium_clone/core/theme/app_theme.dart';
import 'package:medium_clone/presentation/providers/auth_provider.dart';
import 'package:medium_clone/presentation/widgets/common/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    
    if (hasCompletedOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        context.go('/');
      } else {
        context.go('/login');
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _skipOnboarding() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding screens
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: const [
              OnboardingScreen(
                title: 'Discover Great Stories',
                description: 'Read articles from writers around the world on topics you love',
                image: Icon(Icons.article_outlined, size: 100),
              ),
              OnboardingScreen(
                title: 'Follow Your Favorite Writers',
                description: 'Stay updated with content from authors you admire',
                image: Icon(Icons.people_outline, size: 100),
              ),
              OnboardingScreen(
                title: 'Write and Share Your Ideas',
                description: 'Publish your own stories and build your audience',
                image: Icon(Icons.edit_outlined, size: 100),
              ),
            ],
          ),

          // Bottom navigation dots
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? AppColors.primary 
                        : AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ),

          // Next/Get Started button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    text: _currentPage == 2 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage == 2) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;

  const OnboardingScreen({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Image/icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: image),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}
