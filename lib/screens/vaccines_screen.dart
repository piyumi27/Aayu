import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vaccine.dart';
import '../providers/child_provider.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vaccination Schedule'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'Given'),
              Tab(text: 'Upcoming'),
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

            final vaccines = provider.vaccines;
            final vaccineRecords = provider.vaccineRecords;
            final upcomingVaccines = provider.getUpcomingVaccines();
            final overdueVaccines = provider.getOverdueVaccines();
            final givenVaccineIds = vaccineRecords.map((r) => r.vaccineId).toSet();

            return TabBarView(
              children: [
                _buildScheduleTab(context, vaccines, givenVaccineIds, provider),
                _buildGivenTab(context, vaccineRecords, vaccines),
                _buildUpcomingTab(context, upcomingVaccines, overdueVaccines),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleTab(
    BuildContext context,
    List<Vaccine> vaccines,
    Set<String> givenVaccineIds,
    ChildProvider provider,
  ) {
    final ageInMonths = provider.calculateAgeInMonths(provider.selectedChild!.birthDate);
    final groupedVaccines = <String, List<Vaccine>>{};
    
    for (var vaccine in vaccines) {
      final key = _getAgeGroupLabel(vaccine.recommendedAgeMonths);
      groupedVaccines.putIfAbsent(key, () => []).add(vaccine);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedVaccines.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...entry.value.map((vaccine) {
              final isGiven = givenVaccineIds.contains(vaccine.id);
              final isOverdue = !isGiven && vaccine.recommendedAgeMonths < ageInMonths;
              
              return Card(
                color: isGiven
                    ? Colors.green.withValues(alpha: 0.1)
                    : isOverdue
                        ? Colors.red.withValues(alpha: 0.1)
                        : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isGiven
                        ? Colors.green
                        : isOverdue
                            ? Colors.red
                            : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      isGiven ? Icons.check : Icons.vaccines,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(vaccine.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vaccine.nameLocal),
                      Text(
                        vaccine.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (vaccine.isMandatory)
                        Text(
                          'Mandatory',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: !isGiven
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addVaccineRecord(context, vaccine),
                        )
                      : const Icon(Icons.check, color: Colors.green),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildGivenTab(
    BuildContext context,
    List<VaccineRecord> records,
    List<Vaccine> vaccines,
  ) {
    if (records.isEmpty) {
      return const Center(
        child: Text('No vaccines given yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final vaccine = vaccines.firstWhere(
          (v) => v.id == record.vaccineId,
          orElse: () => Vaccine(
            id: '',
            name: 'Unknown',
            nameLocal: '',
            description: '',
            recommendedAgeMonths: 0,
            isMandatory: false,
            category: '',
          ),
        );

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white),
            ),
            title: Text(vaccine.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Given on: ${record.givenDate.toString().split(' ')[0]}'),
                if (record.location != null)
                  Text('Location: ${record.location}'),
                if (record.doctorName != null)
                  Text('Doctor: ${record.doctorName}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTab(
    BuildContext context,
    List<Vaccine> upcoming,
    List<Vaccine> overdue,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty) ...[
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
                        'Overdue Vaccines',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...overdue.map((vaccine) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${vaccine.name} (${vaccine.nameLocal})',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _addVaccineRecord(context, vaccine),
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ),),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Vaccines',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...upcoming.map((vaccine) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.vaccines,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(vaccine.name),
                        subtitle: Text(
                          '${vaccine.nameLocal}\nRecommended at ${vaccine.recommendedAgeMonths} months',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addVaccineRecord(context, vaccine),
                        ),
                      ),),
                ],
              ),
            ),
          ),
        ],
        if (overdue.isEmpty && upcoming.isEmpty)
          const Center(
            child: Text('All vaccines are up to date!'),
          ),
      ],
    );
  }

  String _getAgeGroupLabel(int months) {
    if (months == 0) return 'At Birth';
    if (months < 12) return '$months Month${months > 1 ? 's' : ''}';
    final years = months ~/ 12;
    return '$years Year${years > 1 ? 's' : ''}';
  }

  void _addVaccineRecord(BuildContext context, Vaccine vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddVaccineRecordSheet(vaccine: vaccine),
    );
  }
}

class AddVaccineRecordSheet extends StatefulWidget {
  final Vaccine vaccine;

  const AddVaccineRecordSheet({super.key, required this.vaccine});

  @override
  State<AddVaccineRecordSheet> createState() => _AddVaccineRecordSheetState();
}

class _AddVaccineRecordSheetState extends State<AddVaccineRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _doctorController = TextEditingController();
  final _batchController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _locationController.dispose();
    _doctorController.dispose();
    _batchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Vaccine Record',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          widget.vaccine.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Date: ${_date.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _date = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location/Hospital',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saveRecord,
                  child: const Text('Save Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ChildProvider>();
      final now = DateTime.now();
      
      final record = VaccineRecord(
        id: now.millisecondsSinceEpoch.toString(),
        childId: provider.selectedChild!.id,
        vaccineId: widget.vaccine.id,
        givenDate: _date,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        doctorName: _doctorController.text.isEmpty ? null : _doctorController.text,
        batchNumber: _batchController.text.isEmpty ? null : _batchController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: now,
        updatedAt: now,
      );

      await provider.addVaccineRecord(record);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.vaccine.name} recorded successfully!')),
        );
      }
    }
  }
}