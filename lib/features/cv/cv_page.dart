import 'package:material_ui/material_ui.dart';

class CvPage extends StatelessWidget {
  const CvPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 32 : 20,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [scheme.primaryContainer, scheme.surface],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: wide ? 108 : 84,
                            height: wide ? 108 : 84,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.shadow.withValues(alpha: 0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/profile.PNG',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Michee Luanda',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Développeur junior',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 17),
                                    SizedBox(width: 4),
                                    Text('Goma, RDC'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'À propos',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '''
Informaticien en formation, passionné par les nouvelles technologies et le développement de solutions numériques.
Je développe progressivement mes compétences en programmation, développement web et mobile, intelligence artificielle, cybersécurité et technologies cloud.

Je suis également mécanicien industriel, avec une bonne maîtrise du fonctionnement, de l’entretien et de la réparation des machines industrielles. Doté d’un bon sens de l’analyse et du diagnostic technique, je suis capable d’identifier les pannes et de contribuer efficacement au bon fonctionnement des équipements.
''',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.55),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Compétences',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('HTML5')),
                        Chip(label: Text('JavaScript')),
                        Chip(label: Text('Material Design')),
                        Chip(label: Text('Flutter')),
                        Chip(label: Text('Dart')),
                        Chip(label: Text('Firebase')),
                        Chip(label: Text('Git')),
                        Chip(label: Text('UI/UX Design')),
                        Chip(label: Text('machines mecaniques')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Expérience',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    _TimelineCard(
                      icon: Icons.phone_android_rounded,
                      title: 'opérateur de machine à CONGO TOBACCO COMPANY',
                      subtitle: '2021 — 2023',
                      description: 'Surveillance et reparation de machines',
                    ),
                    const SizedBox(height: 12),
                    _TimelineCard(
                      icon: Icons.school_outlined,
                      title: 'Formation en informatique a l\'ISIG Goma',
                      subtitle: 'Parcours académique · 2023 à nos jours',
                      description: 'Études centrées sur le développement logiciel, les bases de données et les technologies mobiles.',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
