import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/child_provider.dart';
import '../models/growth_record.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.selectedChild == null) {
            return const Center(
              child: Text('Please add a child first'),
            );
          }

          final growthRecords = provider.growthRecords;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentStats(context, provider),
                const SizedBox(height: 24),
                if (growthRecords.length >= 2) ...[
                  _buildGrowthChart(context, growthRecords, 'Weight (kg)', true),
                  const SizedBox(height: 24),
                  _buildGrowthChart(context, growthRecords, 'Height (cm)', false),
                  const SizedBox(height: 24),
                ],
                _buildGrowthHistory(context, growthRecords),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGrowthRecord(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentStats(BuildContext context, ChildProvider provider) {
    final latest = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Measurements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (latest != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Weight',
                      '${latest.weight} kg',
                      Icons.monitor_weight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Height',
                      '${latest.height} cm',
                      Icons.height,
                    ),
                  ),
                ],
              ),
              if (latest.headCircumference != null) ...[
                const SizedBox(height: 16),
                _buildStatItem(
                  context,
                  'Head Circumference',
                  '${latest.headCircumference} cm',
                  Icons.circle_outlined,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Measured on ${latest.date.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              const Text('No measurements recorded yet'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthChart(
    BuildContext context,
    List<GrowthRecord> records,
    String title,
    bool isWeight,
  ) {
    final sortedRecords = List<GrowthRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedRecords.map((record) {
      final monthsFromStart = sortedRecords.first.date.difference(record.date).inDays.abs() / 30;
      final value = isWeight ? record.weight : record.height;
      return FlSpot(monthsFromStart, value);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}m');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthHistory(BuildContext context, List<GrowthRecord> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (records.isEmpty) ...[
              const Text('No growth records yet'),
            ] else ...[
              ...records.take(5).map((record) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text('${record.weight} kg, ${record.height} cm'),
                    subtitle: Text(record.date.toString().split(' ')[0]),
                    trailing: record.notes != null && record.notes!.isNotEmpty
                        ? const Icon(Icons.note, size: 16)
                        : null,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  void _addGrowthRecord(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddGrowthRecordSheet(),
    );
  }
}

class AddGrowthRecordSheet extends StatefulWidget {
  const AddGrowthRecordSheet({super.key});

  @override
  State<AddGrowthRecordSheet> createState() => _AddGrowthRecordSheetState();
}

class _AddGrowthRecordSheetState extends State<AddGrowthRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
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
                  Text(
                    'Add Growth Record',
                    style: Theme.of(context).textTheme.titleLarge,
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
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _headController,
                decoration: const InputDecoration(
                  labelText: 'Head Circumference (cm) - Optional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      
      final record = GrowthRecord(
        id: now.millisecondsSinceEpoch.toString(),
        childId: provider.selectedChild!.id,
        date: _date,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        headCircumference: _headController.text.isEmpty 
            ? null 
            : double.tryParse(_headController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: now,
        updatedAt: now,
      );

      await provider.addGrowthRecord(record);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Growth record added successfully!')),
        );
      }
    }
  }
}