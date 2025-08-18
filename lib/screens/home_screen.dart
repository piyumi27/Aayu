import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/child_provider.dart';
import '../models/child.dart';
import 'add_child_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChildProvider>().loadChildren();
      context.read<ChildProvider>().loadVaccines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ආයු'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.child_care,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Aayu',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add your child to get started'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _addChild(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Child'),
                  ),
                ],
              ),
            );
          }

          final selectedChild = provider.selectedChild;
          if (selectedChild == null) return const SizedBox();

          final ageInMonths = provider.calculateAgeInMonths(selectedChild.birthDate);
          final upcomingVaccines = provider.getUpcomingVaccines();
          final overdueVaccines = provider.getOverdueVaccines();
          final latestGrowth = provider.growthRecords.isNotEmpty 
              ? provider.growthRecords.first 
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChildCard(context, selectedChild, provider),
                const SizedBox(height: 16),
                _buildQuickStats(context, latestGrowth, ageInMonths),
                const SizedBox(height: 16),
                if (overdueVaccines.isNotEmpty) ...[
                  _buildAlertCard(
                    context,
                    'Overdue Vaccines',
                    '${overdueVaccines.length} vaccine(s) are overdue',
                    Icons.warning,
                    Colors.red,
                    () => context.go('/vaccines'),
                  ),
                  const SizedBox(height: 16),
                ],
                if (upcomingVaccines.isNotEmpty) ...[
                  _buildAlertCard(
                    context,
                    'Upcoming Vaccines',
                    '${upcomingVaccines.length} vaccine(s) coming up',
                    Icons.vaccines,
                    Colors.orange,
                    () => context.go('/vaccines'),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.children.isEmpty) return const SizedBox();
          return FloatingActionButton(
            onPressed: () => _addChild(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, Child child, ChildProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                child.name[0].toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${provider.getAgeString(child.birthDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Gender: ${child.gender}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (provider.children.length > 1)
              PopupMenuButton<Child>(
                onSelected: (selected) => provider.selectChild(selected),
                itemBuilder: (context) => provider.children
                    .map((c) => PopupMenuItem(
                          value: c,
                          child: Text(c.name),
                        ))
                    .toList(),
                child: const Icon(Icons.arrow_drop_down),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic latestGrowth, int ageInMonths) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monitor_weight_outlined,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Weight'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latestGrowth != null
                        ? '${latestGrowth.weight} kg'
                        : 'No data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.height,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Height'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    latestGrowth != null
                        ? '${latestGrowth.height} cm'
                        : 'No data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: [
            _buildActionCard(
              context,
              'Add Growth',
              Icons.trending_up,
              () => context.go('/growth'),
            ),
            _buildActionCard(
              context,
              'Add Vaccine',
              Icons.vaccines,
              () => context.go('/vaccines'),
            ),
            _buildActionCard(
              context,
              'View Charts',
              Icons.bar_chart,
              () => context.go('/growth'),
            ),
            _buildActionCard(
              context,
              'Learn',
              Icons.school,
              () => context.go('/learn'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }

  void _addChild(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChildScreen(),
      ),
    );
  }
}