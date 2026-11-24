import 'package:material_ui/material_ui.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final members = const [
      ('Mère', 'Riziki Mubogo', 'Pilier de la famille', 'RM', 'assets/images/maman.jpg'),
      ('Sœur', 'Laurence Doma', 'eleve', 'LD', 'assets/images/soeur.jpg'),
    ];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 600
              ? 2
              : 1;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth >= 700 ? 32 : 20,
                  24,
                  constraints.maxWidth >= 700 ? 32 : 20,
                  12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ma famille',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Les personnes qui donnent du sens à mon parcours.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth >= 700 ? 32 : 20,
                  0,
                  constraints.maxWidth >= 700 ? 32 : 20,
                  28,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final member = members[index];
                    return _MemberCard(
                      relation: member.$1,
                      name: member.$2,
                      description: member.$3,
                      initials: member.$4,
                      imagePath: member.$5,
                    );
                  }, childCount: members.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 178,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.relation,
    required this.name,
    required this.description,
    required this.initials,
    this.imagePath,
  });
  final String relation, name, description, initials;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: imagePath == null
                        ? Container(
                      alignment: Alignment.center,
                      color: scheme.primaryContainer,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                        : Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relation,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
