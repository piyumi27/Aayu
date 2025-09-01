import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../providers/child_provider.dart';
import '../services/medication_service.dart';
import '../utils/responsive_utils.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MedicationService _medicationService = MedicationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _medicationService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications & Supplements'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.w600,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'Today'),
            Tab(icon: Icon(Icons.medication), text: 'Active'),
            Tab(icon: Icon(Icons.analytics), text: 'History'),
            Tab(icon: Icon(Icons.assessment), text: 'Stats'),
          ],
        ),
      ),
      body: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.selectedChild == null) {
            return const Center(
              child: Text('Please add a child first'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodayTab(context, provider.selectedChild!.id),
              _buildActiveMedicationsTab(context, provider.selectedChild!.id),
              _buildHistoryTab(context, provider.selectedChild!.id),
              _buildStatsTab(context, provider.selectedChild!.id),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(context),
        backgroundColor: const Color(0xFF0086FF),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context, String childId) {
    return ChangeNotifierBuilder<MedicationService>(
      notifier: _medicationService,
      builder: (context, service, child) {
        final todaysDoses = service.getTodaysDoses(childId);
        final overdueMeds = service.getOverdueMedications(childId);
        final upcomingMeds = service.getUpcomingMedications(childId);

        return RefreshIndicator(
          onRefresh: () async {
            await service.loadMedications();
            await service.loadDoseRecords();
          },
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            children: [
              // Overdue medications alert
              if (overdueMeds.isNotEmpty) ...[
                Card(
                  color: Colors.red.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'Overdue Medications',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...overdueMeds.map((med) => _buildOverdueMedicationTile(context, med)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Upcoming medications
              if (upcomingMeds.isNotEmpty) ...[
                Card(
                  color: Colors.orange.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Upcoming (Next 2 Hours)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...upcomingMeds.map((med) => _buildUpcomingMedicationTile(context, med)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Today's schedule
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Schedule',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (todaysDoses.isEmpty)
                        const Text('No scheduled doses for today')
                      else
                        ...todaysDoses.map((dose) => _buildDoseRecordTile(context, dose)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveMedicationsTab(BuildContext context, String childId) {
    return ChangeNotifierBuilder<MedicationService>(
      notifier: _medicationService,
      builder: (context, service, child) {
        final activeMeds = service.getActiveMedicationsForChild(childId);
        final supplements = activeMeds.where((m) => m.type == MedicationType.supplement).toList();
        final medicines = activeMeds.where((m) => m.type == MedicationType.medicine).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await service.loadMedications();
          },
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            children: [
              if (supplements.isNotEmpty) ...[
                Text(
                  'Supplements & Vitamins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...supplements.map((med) => _buildMedicationCard(context, med)),
                const SizedBox(height: 16),
              ],

              if (medicines.isNotEmpty) ...[
                Text(
                  'Medications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...medicines.map((med) => _buildMedicationCard(context, med)),
              ],

              if (activeMeds.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No active medications'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, String childId) {
    return ChangeNotifierBuilder<MedicationService>(
      notifier: _medicationService,
      builder: (context, service, child) {
        final allMeds = service.getMedicationsForChild(childId);
        final completedMeds = allMeds.where((m) => m.status == MedicationStatus.completed).toList();
        final discontinuedMeds = allMeds.where((m) => m.status == MedicationStatus.discontinued).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await service.loadMedications();
          },
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            children: [
              if (completedMeds.isNotEmpty) ...[
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                ...completedMeds.map((med) => _buildMedicationCard(context, med, isHistory: true)),
                const SizedBox(height: 16),
              ],

              if (discontinuedMeds.isNotEmpty) ...[
                Text(
                  'Discontinued',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...discontinuedMeds.map((med) => _buildMedicationCard(context, med, isHistory: true)),
              ],

              if (completedMeds.isEmpty && discontinuedMeds.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No medication history'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(BuildContext context, String childId) {
    return ChangeNotifierBuilder<MedicationService>(
      notifier: _medicationService,
      builder: (context, service, child) {
        final stats = service.getMedicationStats(childId);
        final activeMeds = service.getActiveMedicationsForChild(childId);

        return RefreshIndicator(
          onRefresh: () async {
            await service.loadMedications();
          },
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total',
                              stats['total'].toString(),
                              Icons.medication,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Active',
                              stats['active'].toString(),
                              Icons.play_circle,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Supplements',
                              stats['supplements'].toString(),
                              Icons.healing,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Medicines',
                              stats['medications'].toString(),
                              Icons.local_pharmacy,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Adherence stats for active medications
              if (activeMeds.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adherence (Last 7 Days)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...activeMeds.map((med) => _buildAdherenceCard(context, med, service)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationCard(BuildContext context, Medication medication, {bool isHistory = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getMedicationColor(medication.type),
          child: Icon(
            _getMedicationIcon(medication.type),
            color: Colors.white,
          ),
        ),
        title: Text(medication.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medication.nameLocal),
            Text(
              '${medication.dosageText} • ${medication.frequencyText}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (medication.indication != null)
              Text(
                medication.indication!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: isHistory
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) => _handleMedicationAction(context, medication, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'pause', child: Text('Pause')),
                  const PopupMenuItem(value: 'stop', child: Text('Stop')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
        onTap: () => _showMedicationDetails(context, medication),
      ),
    );
  }

  Widget _buildOverdueMedicationTile(BuildContext context, Medication medication) {
    return ListTile(
      leading: const Icon(Icons.warning, color: Colors.red, size: 20),
      title: Text(
        medication.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${medication.dosageText} overdue'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _recordDose(context, medication),
            child: const Text('Take'),
          ),
          TextButton(
            onPressed: () => _skipDose(context, medication),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMedicationTile(BuildContext context, Medication medication) {
    return ListTile(
      leading: const Icon(Icons.schedule, color: Colors.orange, size: 20),
      title: Text(
        medication.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${medication.dosageText} upcoming'),
      trailing: TextButton(
        onPressed: () => _recordDose(context, medication),
        child: const Text('Take Now'),
      ),
    );
  }

  Widget _buildDoseRecordTile(BuildContext context, MedicationDoseRecord dose) {
    return ListTile(
      leading: Icon(
        dose.statusIcon,
        color: dose.statusColor,
      ),
      title: Text('Dose at ${_formatTime(dose.scheduledTime)}'),
      subtitle: Text(dose.isTaken
          ? 'Taken at ${dose.actualTime != null ? _formatTime(dose.actualTime!) : "N/A"}'
          : dose.isSkipped
              ? 'Skipped'
              : 'Scheduled'),
      trailing: dose.isTaken || dose.isSkipped
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _recordDoseFromRecord(context, dose),
                  child: const Text('Take'),
                ),
                TextButton(
                  onPressed: () => _skipDoseFromRecord(context, dose),
                  child: const Text('Skip'),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(BuildContext context, Medication medication, MedicationService service) {
    final adherence = service.getMedicationAdherence(medication.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: adherence['adherence']! / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(
                      adherence['adherence']! >= 80
                          ? Colors.green
                          : adherence['adherence']! >= 60
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${adherence['adherence']!.toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Taken: ${adherence['taken']!.toStringAsFixed(0)}% • '
              'Skipped: ${adherence['skipped']!.toStringAsFixed(0)}% • '
              'Missed: ${adherence['missed']!.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMedicationColor(MedicationType type) {
    switch (type) {
      case MedicationType.supplement:
        return Colors.orange;
      case MedicationType.vitamin:
        return Colors.green;
      case MedicationType.medicine:
        return Colors.blue;
      case MedicationType.prescription:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMedicationIcon(MedicationType type) {
    switch (type) {
      case MedicationType.supplement:
        return Icons.healing;
      case MedicationType.vitamin:
        return Icons.eco;
      case MedicationType.medicine:
        return Icons.medication;
      case MedicationType.prescription:
        return Icons.local_pharmacy;
      default:
        return Icons.medical_services;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showAddMedicationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddMedicationSheet(),
    );
  }

  void _showMedicationDetails(BuildContext context, Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MedicationDetailsSheet(medication: medication),
    );
  }

  void _handleMedicationAction(BuildContext context, Medication medication, String action) {
    switch (action) {
      case 'edit':
        _showEditMedicationDialog(context, medication);
        break;
      case 'pause':
        _pauseMedication(context, medication);
        break;
      case 'stop':
        _stopMedication(context, medication);
        break;
      case 'delete':
        _deleteMedication(context, medication);
        break;
    }
  }

  void _showEditMedicationDialog(BuildContext context, Medication medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditMedicationSheet(medication: medication),
    );
  }

  void _pauseMedication(BuildContext context, Medication medication) async {
    final updated = medication.copyWith(
      status: MedicationStatus.paused,
      updatedAt: DateTime.now(),
    );
    
    final success = await _medicationService.updateMedication(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medication.name} paused')),
      );
    }
  }

  void _stopMedication(BuildContext context, Medication medication) async {
    final updated = medication.copyWith(
      status: MedicationStatus.completed,
      endDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final success = await _medicationService.updateMedication(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medication.name} stopped')),
      );
    }
  }

  void _deleteMedication(BuildContext context, Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _medicationService.deleteMedication(medication.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${medication.name} deleted')),
        );
      }
    }
  }

  void _recordDose(BuildContext context, Medication medication) async {
    final success = await _medicationService.recordDoseTaken(medication.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medication.name} dose recorded')),
      );
    }
  }

  void _skipDose(BuildContext context, Medication medication) async {
    final success = await _medicationService.recordDoseSkipped(medication.id, 'User skipped');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medication.name} dose skipped')),
      );
    }
  }

  void _recordDoseFromRecord(BuildContext context, MedicationDoseRecord dose) async {
    final success = await _medicationService.recordDoseTaken(dose.medicationId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose recorded')),
      );
    }
  }

  void _skipDoseFromRecord(BuildContext context, MedicationDoseRecord dose) async {
    final success = await _medicationService.recordDoseSkipped(dose.medicationId, 'User skipped');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dose skipped')),
      );
    }
  }
}

// Helper widget for ChangeNotifier listening
class ChangeNotifierBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final T notifier;
  final Widget Function(BuildContext, T, Widget?) builder;
  final Widget? child;

  const ChangeNotifierBuilder({
    super.key,
    required this.notifier,
    required this.builder,
    this.child,
  });

  @override
  State<ChangeNotifierBuilder<T>> createState() => _ChangeNotifierBuilderState<T>();
}

class _ChangeNotifierBuilderState<T extends ChangeNotifier> extends State<ChangeNotifierBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onNotifierChange);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onNotifierChange);
    super.dispose();
  }

  void _onNotifierChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.notifier, widget.child);
  }
}

// Placeholder sheets - would be implemented separately
class AddMedicationSheet extends StatelessWidget {
  const AddMedicationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Add Medication Form'),
      ),
    );
  }
}

class EditMedicationSheet extends StatelessWidget {
  final Medication medication;
  
  const EditMedicationSheet({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Edit Medication Form'),
      ),
    );
  }
}

class MedicationDetailsSheet extends StatelessWidget {
  final Medication medication;
  
  const MedicationDetailsSheet({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Medication Details View'),
      ),
    );
  }
}