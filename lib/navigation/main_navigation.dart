import 'package:flutter/material.dart';

import '../features/cv/cv_page.dart';
import '../features/family/family_page.dart';
import '../features/contact/contact_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final _pages = const [CvPage(), FamilyPage(), ContactPage()];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.badge_outlined),
      selectedIcon: Icon(Icons.badge_rounded),
      label: 'CV',
    ),
    NavigationDestination(
      icon: Icon(Icons.family_restroom_outlined),
      selectedIcon: Icon(Icons.family_restroom_rounded),
      label: 'Famille',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      selectedIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Contact',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final content = IndexedStack(index: _index, children: _pages);

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (index) =>
                      setState(() => _index = index),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircleAvatar(radius: 24, child: Text('ML')),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.badge_outlined),
                      selectedIcon: Icon(Icons.badge_rounded),
                      label: Text('CV'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.family_restroom_outlined),
                      selectedIcon: Icon(Icons.family_restroom_rounded),
                      label: Text('Famille'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline_rounded),
                      selectedIcon: Icon(Icons.chat_bubble_rounded),
                      label: Text('Contact'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          body: content,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            destinations: _destinations,
          ),
        );
      },
    );
  }
}
