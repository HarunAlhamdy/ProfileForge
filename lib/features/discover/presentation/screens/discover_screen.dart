import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/data/profile_firestore_dto.dart';
import '../../../profile/data/portfolio_firestore_service.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../../core_ui/atoms/shimmer_loading.dart';

/// AI-powered search: describe who you're looking for, get matching portfolios.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _queryController = TextEditingController();
  bool _loading = false;
  List<PublicPortfolio> _allPortfolios = [];
  List<PublicPortfolio> _results = [];
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = 'Describe who you\'re looking for';
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });

    try {
      // In production, inject AiDiscoveryService with API key from env/Firebase Remote Config
      // For now we do keyword-based matching on searchText
      final portfolios = await FirebaseFirestore.instance
          .collection('portfolios')
          .where('published', isEqualTo: true)
          .get();
      final list = portfolios.docs.map((d) {
        final data = d.data();
        final profile = ProfileFirestoreDto.fromMap(data);
        return PublicPortfolio(userId: d.id, profile: profile);
      }).toList();

      final lowerQuery = query.toLowerCase();
      final words = lowerQuery
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .toList();
      final matches = <PublicPortfolio>[];
      for (final p in list) {
        final searchable =
            '${p.profile.fullName} ${p.profile.headline} ${p.profile.bio} '
                    '${p.profile.skills.map((s) => s.name).join(' ')} '
                    '${p.profile.experience.map((e) => '${e.role} ${e.company} ${e.description}').join(' ')}'
                .toLowerCase();
        final score = words.where((w) => searchable.contains(w)).length;
        if (score > 0) matches.add(p);
      }
      matches.sort((a, b) {
        final aText = '${a.profile.fullName} ${a.profile.headline}';
        final bText = '${b.profile.fullName} ${b.profile.headline}';
        final aScore = words
            .where((w) => aText.toLowerCase().contains(w))
            .length;
        final bScore = words
            .where((w) => bText.toLowerCase().contains(w))
            .length;
        return bScore.compareTo(aScore);
      });

      if (!mounted) return;
      setState(() {
        _allPortfolios = list;
        _results = matches.isEmpty ? list : matches;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Search failed. Make sure Firebase is configured.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Find people that match',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe the type of person you\'re looking for (e.g. "Flutter developer with backend experience")',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. UI designer, Python dev...',
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _loading ? null : _search,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _loading && _results.isEmpty
                ? Center(
                    child: ShimmerLoading(child: _buildShimmerCard(context)),
                  )
                : _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search or browse Explore',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final p = _results[i];
                      return _PortfolioTile(
                        profile: p.profile,
                        onTap: () => context.push('/profile/${p.userId}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.profile, required this.onTap});

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skills = profile.skills.take(3).map((s) => s.name).join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          child: Text(
            profile.fullName.isEmpty ? '?' : profile.fullName[0].toUpperCase(),
          ),
        ),
        title: Text(
          profile.fullName.isEmpty ? 'Anonymous' : profile.fullName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (profile.headline.isNotEmpty) profile.headline,
            if (skills.isNotEmpty) skills,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
