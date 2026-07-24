import 'package:flutter/material.dart';
import '../responsive/window_size.dart';

class AdaptiveNavigationDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final VoidCallback onTap;

  AdaptiveNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });
}

class AdaptiveShell extends StatelessWidget {
  final int selectedIndex;
  final List<AdaptiveNavigationDestination> destinations;
  final Widget child;

  const AdaptiveShell({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (idx) => destinations[idx].onTap(),
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      );
    }

    if (context.isMedium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => destinations[idx].onTap(),
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                for (var i = 0; i < destinations.length; i++)
                  ListTile(
                    leading: Icon(i == selectedIndex
                        ? destinations[i].selectedIcon
                        : destinations[i].icon),
                    title: Text(destinations[i].label),
                    selected: i == selectedIndex,
                    onTap: destinations[i].onTap,
                  )
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
