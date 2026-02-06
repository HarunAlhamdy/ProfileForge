import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../profile/data/profile_firestore_dto.dart';
import '../../domain/models/profile_model.dart';
import '../../../../core_ui/atoms/profile_strength_meter.dart';
import '../../domain/profile_strength.dart';

/// Read-only view of another user's portfolio.
class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('portfolios').doc(userId).get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }
          if (snap.hasError || !snap.hasData || !snap.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 24),
                  Text('Portfolio not found', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('This user may have unpublished their portfolio', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }
          final data = snap.data!.data() ?? {};
          if (data['published'] != true) {
            return Center(
              child: Text('This portfolio is private', style: Theme.of(context).textTheme.titleMedium),
            );
          }
          final profile = ProfileFirestoreDto.fromMap(data);
          return _ProfileBody(profile: profile);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(
            fullName: profile.fullName,
            headline: profile.headline,
            isDark: isDark,
            strength: profileStrength(profile),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (profile.bio.isNotEmpty || profile.email.isNotEmpty) ...[
                _CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.bio.isNotEmpty) Text(profile.bio, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: colorScheme.onSurface)),
                      if (profile.bio.isNotEmpty && profile.email.isNotEmpty) const SizedBox(height: 16),
                      if (profile.email.isNotEmpty) _EmailChip(email: profile.email),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.skills.isNotEmpty) ...[
                _SectionTitle(title: 'Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: profile.skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(s.name, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              if (profile.experience.isNotEmpty) ...[
                _SectionTitle(title: 'Experience'),
                const SizedBox(height: 10),
                ...profile.experience.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CardSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.role, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (e.company.isNotEmpty) Text(e.company, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                          if (e.period.isNotEmpty) Text(e.period, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          if (e.description.isNotEmpty) ...[const SizedBox(height: 8), Text(e.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4))],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (profile.links.isNotEmpty) ...[
                _SectionTitle(title: 'Links'),
                const SizedBox(height: 10),
                ...profile.links.map((l) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _LinkTile(link: l))),
              ],
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.fullName, required this.headline, required this.isDark, this.strength = 0});

  final String fullName;
  final String headline;
  final bool isDark;
  final double strength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [const Color(0xFF4338CA), const Color(0xFF7C3AED)] : [const Color(0xFF6366F1), const Color(0xFFA855F7)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(
                fullName.isEmpty ? '?' : fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            fullName.isEmpty ? 'Anonymous' : fullName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          if (headline.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(headline, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center),
          ],
          if (strength > 0) ...[
            const SizedBox(height: 16),
            ProfileStrengthMeter(strength: strength, size: 44, strokeWidth: 4, backgroundColor: Colors.white.withValues(alpha: 0.3), foregroundColor: Colors.white),
          ],
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.2));
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({required this.email});
  final String email;

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openMail(context),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.email_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(email, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.link});
  final ProfileLink link;

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(link.url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openUrl(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.link, size: 20, color: colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(link.title.isEmpty ? link.url : link.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    if (link.title.isNotEmpty && link.url != link.title) Text(link.url, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
