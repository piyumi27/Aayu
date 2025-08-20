import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _birthHeightController = TextEditingController();
  
  DateTime? _birthDate;
  String _gender = 'Male';
  String? _bloodType;

  @override
  void dispose() {
    _nameController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Child'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _birthDate == null
                      ? 'Select Birth Date'
                      : 'Birth Date: ${_birthDate!.toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _birthDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _birthWeightController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _birthHeightController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Height (cm)',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _bloodType,
                decoration: const InputDecoration(
                  labelText: 'Blood Type (Optional)',
                  prefixIcon: Icon(Icons.bloodtype),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Not specified')),
                  ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _bloodType = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saveChild,
                  child: const Text('Save Child'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChild() async {
    if (_formKey.currentState!.validate()) {
      if (_birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select birth date')),
        );
        return;
      }

      final now = DateTime.now();
      final child = Child(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        birthDate: _birthDate!,
        gender: _gender,
        birthWeight: _birthWeightController.text.isEmpty
            ? null
            : double.tryParse(_birthWeightController.text),
        birthHeight: _birthHeightController.text.isEmpty
            ? null
            : double.tryParse(_birthHeightController.text),
        bloodType: _bloodType,
        photoUrl: null,
        createdAt: now,
        updatedAt: now,
      );

      await context.read<ChildProvider>().addChild(child);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${child.name} added successfully!')),
        );
      }
    }
  }
}