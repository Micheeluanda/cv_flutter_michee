import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _phone = '0975985796';
  static const _email = 'luandamichee@gmail.com';
  static const _location = 'Goma, Nord-Kivu, RDC';
  static const _linkedIn = 'https://www.linkedin.com/in/michée-luanda-b921a03b1/';
  static const _gitHub = 'https://github.com/Micheeluanda';

  Future<void> _open(Uri uri, BuildContext context) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir ce lien.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.connect_without_contact_rounded,
                  size: 30, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text('Restons en contact',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Disponible pour échanger autour d’un projet, d’une collaboration ou d’une opportunité professionnelle.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: scheme.onSurfaceVariant, height: 1.45),
            ),
          ],
        );

        final cards = Column(children: [
          _ContactCard(
            icon: Icons.phone_rounded,
            title: 'Téléphone',
            value: _phone,
            actionLabel: 'Appeler',
            onTap: () => _open(Uri(scheme: 'tel', path: _phone), context),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.mail_rounded,
            title: 'Adresse e-mail',
            value: _email,
            actionLabel: 'Écrire',
            onTap: () => _open(
              Uri(scheme: 'mailto', path: _email),
              context,
            ),
          ),
          const SizedBox(height: 12),
          const _ContactCard(
            icon: Icons.location_on_rounded,
            title: 'Localisation',
            value: _location,
          ),
        ]);

        final socialCards = Row(children: [
          Expanded(
            child: _SocialCard(
              icon: Icons.business_rounded,
              title: 'LinkedIn',
              subtitle: 'Voir le profil',
              onTap: () => _open(Uri.parse(_linkedIn), context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SocialCard(
              icon: Icons.code_rounded,
              title: 'GitHub',
              subtitle: 'Voir les projets',
              onTap: () => _open(Uri.parse(_gitHub), context),
            ),
          ),
        ]);

        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 32 : 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 24),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards),
                        const SizedBox(width: 24),
                        Expanded(child: Column(children: [socialCards])),
                      ],
                    )
                  else
                    Column(children: [cards, const SizedBox(height: 18), socialCards]),
                  const SizedBox(height: 18),
                  if (wide) const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ]),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onTap, child: Text(actionLabel!)),
        ]),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  const _SocialCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: scheme.onSecondaryContainer),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Row(children: [
              Expanded(
                child: Text(subtitle,
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
              Icon(Icons.arrow_outward_rounded,
                  size: 19, color: scheme.primary),
            ]),
          ]),
        ),
      ),
    );
  }
}
