import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'home_feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'GeoMentor',
          style: TextStyle(color: AppColors.primary),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome to GeoMentor!',
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your journey starts here.',
                      style: AppTextStyles.subhead.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {},
                        child: Text('Get Started', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ),
              // Add more sections below as you expand the design
              const SizedBox(height: 48),
              // Features Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Features',
                  style: AppTextStyles.subhead.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 16),
              HomeFeatureCard(
                icon: Icons.map,
                title: 'Interactive Maps',
                description:
                    'Explore and interact with rich, dynamic maps tailored for your needs.',
                onTap: () {},
              ),
              HomeFeatureCard(
                icon: Icons.school,
                title: 'Learning Modules',
                description:
                    'Access curated educational content and track your progress easily.',
                onTap: () {},
              ),
              HomeFeatureCard(
                icon: Icons.people,
                title: 'Community',
                description:
                    'Connect, collaborate, and grow with fellow learners and mentors.',
                onTap: () {},
              ),
              const SizedBox(height: 48),
              // Placeholder for next section
              Text('More content coming soon...', style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
