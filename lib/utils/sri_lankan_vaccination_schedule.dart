import '../models/vaccine.dart';

/// Sri Lankan National Immunization Schedule
/// Based on Ministry of Health guidelines (2024)
class SriLankanVaccinationSchedule {
  static final List<Vaccine> vaccines = [
    // Birth vaccines
    Vaccine(
      id: 'bcg_birth',
      name: 'BCG',
      nameLocal: 'බී.සී.ජී.',
      description: 'Bacille Calmette-Guérin vaccine against tuberculosis',
      recommendedAgeMonths: 0,
      isMandatory: true,
      category: 'Birth',
    ),
    Vaccine(
      id: 'hepatitis_b_birth',
      name: 'Hepatitis B (Birth dose)',
      nameLocal: 'හෙපටයිටිස් B (උපත)',
      description: 'First dose of Hepatitis B vaccine',
      recommendedAgeMonths: 0,
      isMandatory: true,
      category: 'Birth',
    ),

    // 2 months
    Vaccine(
      id: 'pentavalent_1',
      name: 'Pentavalent 1',
      nameLocal: 'පෙන්ටවලන්ට් 1',
      description: 'Combined vaccine: DPT + Hepatitis B + Hib',
      recommendedAgeMonths: 2,
      isMandatory: true,
      category: '2 Months',
    ),
    Vaccine(
      id: 'opv_1',
      name: 'OPV 1',
      nameLocal: 'පෝලියෝ 1',
      description: 'Oral Polio Vaccine - First dose',
      recommendedAgeMonths: 2,
      isMandatory: true,
      category: '2 Months',
    ),
    Vaccine(
      id: 'pneumococcal_1',
      name: 'PCV 1',
      nameLocal: 'PCV 1',
      description: 'Pneumococcal Conjugate Vaccine - First dose',
      recommendedAgeMonths: 2,
      isMandatory: true,
      category: '2 Months',
    ),
    Vaccine(
      id: 'rotavirus_1',
      name: 'Rotavirus 1',
      nameLocal: 'රොටවයිරස් 1',
      description: 'Rotavirus vaccine - First dose',
      recommendedAgeMonths: 2,
      isMandatory: true,
      category: '2 Months',
    ),

    // 4 months
    Vaccine(
      id: 'pentavalent_2',
      name: 'Pentavalent 2',
      nameLocal: 'පෙන්ටවලන්ට් 2',
      description: 'Combined vaccine: DPT + Hepatitis B + Hib - Second dose',
      recommendedAgeMonths: 4,
      isMandatory: true,
      category: '4 Months',
    ),
    Vaccine(
      id: 'opv_2',
      name: 'OPV 2',
      nameLocal: 'පෝලියෝ 2',
      description: 'Oral Polio Vaccine - Second dose',
      recommendedAgeMonths: 4,
      isMandatory: true,
      category: '4 Months',
    ),
    Vaccine(
      id: 'pneumococcal_2',
      name: 'PCV 2',
      nameLocal: 'PCV 2',
      description: 'Pneumococcal Conjugate Vaccine - Second dose',
      recommendedAgeMonths: 4,
      isMandatory: true,
      category: '4 Months',
    ),
    Vaccine(
      id: 'rotavirus_2',
      name: 'Rotavirus 2',
      nameLocal: 'රොටවයිරස් 2',
      description: 'Rotavirus vaccine - Second dose',
      recommendedAgeMonths: 4,
      isMandatory: true,
      category: '4 Months',
    ),

    // 6 months
    Vaccine(
      id: 'pentavalent_3',
      name: 'Pentavalent 3',
      nameLocal: 'පෙන්ටවලන්ට් 3',
      description: 'Combined vaccine: DPT + Hepatitis B + Hib - Third dose',
      recommendedAgeMonths: 6,
      isMandatory: true,
      category: '6 Months',
    ),
    Vaccine(
      id: 'opv_3',
      name: 'OPV 3',
      nameLocal: 'පෝලියෝ 3',
      description: 'Oral Polio Vaccine - Third dose',
      recommendedAgeMonths: 6,
      isMandatory: true,
      category: '6 Months',
    ),
    Vaccine(
      id: 'pneumococcal_3',
      name: 'PCV 3',
      nameLocal: 'PCV 3',
      description: 'Pneumococcal Conjugate Vaccine - Third dose',
      recommendedAgeMonths: 6,
      isMandatory: true,
      category: '6 Months',
    ),
    Vaccine(
      id: 'ipv',
      name: 'IPV',
      nameLocal: 'IPV',
      description: 'Inactivated Polio Vaccine',
      recommendedAgeMonths: 6,
      isMandatory: true,
      category: '6 Months',
    ),

    // 9 months
    Vaccine(
      id: 'mmr_1',
      name: 'MMR 1',
      nameLocal: 'MMR 1',
      description: 'Measles, Mumps, Rubella vaccine - First dose',
      recommendedAgeMonths: 9,
      isMandatory: true,
      category: '9 Months',
    ),
    Vaccine(
      id: 'japanese_encephalitis_1',
      name: 'JE 1',
      nameLocal: 'JE 1',
      description: 'Japanese Encephalitis vaccine - First dose',
      recommendedAgeMonths: 9,
      isMandatory: true,
      category: '9 Months',
    ),

    // 12 months
    Vaccine(
      id: 'pneumococcal_booster',
      name: 'PCV Booster',
      nameLocal: 'PCV බූස්ටර්',
      description: 'Pneumococcal Conjugate Vaccine - Booster dose',
      recommendedAgeMonths: 12,
      isMandatory: true,
      category: '12 Months',
    ),
    Vaccine(
      id: 'japanese_encephalitis_2',
      name: 'JE 2',
      nameLocal: 'JE 2',
      description: 'Japanese Encephalitis vaccine - Second dose',
      recommendedAgeMonths: 12,
      isMandatory: true,
      category: '12 Months',
    ),

    // 18 months
    Vaccine(
      id: 'dpt_booster_1',
      name: 'DPT Booster 1',
      nameLocal: 'DPT බූස්ටර් 1',
      description: 'Diphtheria, Pertussis, Tetanus - First booster',
      recommendedAgeMonths: 18,
      isMandatory: true,
      category: '18 Months',
    ),
    Vaccine(
      id: 'mmr_2',
      name: 'MMR 2',
      nameLocal: 'MMR 2',
      description: 'Measles, Mumps, Rubella vaccine - Second dose',
      recommendedAgeMonths: 18,
      isMandatory: true,
      category: '18 Months',
    ),
    Vaccine(
      id: 'vitamin_a_1',
      name: 'Vitamin A 1',
      nameLocal: 'විටමින් A 1',
      description: 'Vitamin A supplementation - First dose',
      recommendedAgeMonths: 18,
      isMandatory: true,
      category: '18 Months',
    ),

    // 3 years (36 months)
    Vaccine(
      id: 'dpt_booster_2',
      name: 'DPT Booster 2',
      nameLocal: 'DPT බූස්ටර් 2',
      description: 'Diphtheria, Pertussis, Tetanus - Second booster',
      recommendedAgeMonths: 36,
      isMandatory: true,
      category: '3 Years',
    ),
    Vaccine(
      id: 'opv_booster',
      name: 'OPV Booster',
      nameLocal: 'පෝලියෝ බූස්ටර්',
      description: 'Oral Polio Vaccine - Booster dose',
      recommendedAgeMonths: 36,
      isMandatory: true,
      category: '3 Years',
    ),
    Vaccine(
      id: 'vitamin_a_2',
      name: 'Vitamin A 2',
      nameLocal: 'විටමින් A 2',
      description: 'Vitamin A supplementation - Second dose',
      recommendedAgeMonths: 36,
      isMandatory: true,
      category: '3 Years',
    ),

    // School entry (5 years / 60 months)
    Vaccine(
      id: 'dpt_school_entry',
      name: 'DPT (School Entry)',
      nameLocal: 'DPT (පාසල් ප්‍රවේශය)',
      description: 'Diphtheria, Pertussis, Tetanus - School entry booster',
      recommendedAgeMonths: 60,
      isMandatory: true,
      category: 'School Entry',
    ),

    // Optional vaccines (recommended but not mandatory)
    Vaccine(
      id: 'hepatitis_a',
      name: 'Hepatitis A',
      nameLocal: 'හෙපටයිටිස් A',
      description: 'Hepatitis A vaccine (optional)',
      recommendedAgeMonths: 12,
      isMandatory: false,
      category: 'Optional',
    ),
    Vaccine(
      id: 'varicella',
      name: 'Varicella (Chickenpox)',
      nameLocal: 'වැනරෝග',
      description: 'Chickenpox vaccine (optional)',
      recommendedAgeMonths: 12,
      isMandatory: false,
      category: 'Optional',
    ),
    Vaccine(
      id: 'influenza_annual',
      name: 'Influenza (Annual)',
      nameLocal: 'ඉන්ෆ්ලුවෙන්සා (වාර්ෂික)',
      description: 'Annual flu vaccine (optional)',
      recommendedAgeMonths: 6,
      isMandatory: false,
      category: 'Optional',
    ),
  ];

  /// Get vaccines due at specific age
  static List<Vaccine> getVaccinesDueAtAge(int ageInMonths) {
    return vaccines
        .where((vaccine) => vaccine.recommendedAgeMonths == ageInMonths)
        .toList();
  }

  /// Get overdue vaccines for child age
  static List<Vaccine> getOverdueVaccines(int ageInMonths, Set<String> givenVaccineIds) {
    return vaccines
        .where((vaccine) => 
            !givenVaccineIds.contains(vaccine.id) &&
            vaccine.recommendedAgeMonths < ageInMonths)
        .toList();
  }

  /// Get upcoming vaccines (due in next 2 months)
  static List<Vaccine> getUpcomingVaccines(int ageInMonths, Set<String> givenVaccineIds) {
    return vaccines
        .where((vaccine) => 
            !givenVaccineIds.contains(vaccine.id) &&
            vaccine.recommendedAgeMonths > ageInMonths &&
            vaccine.recommendedAgeMonths <= ageInMonths + 2)
        .toList();
  }

  /// Get vaccination schedule for age range
  static Map<String, List<Vaccine>> getScheduleByAgeGroup() {
    final schedule = <String, List<Vaccine>>{};
    
    for (final vaccine in vaccines) {
      final ageGroup = _getAgeGroupForMonths(vaccine.recommendedAgeMonths);
      schedule.putIfAbsent(ageGroup, () => []).add(vaccine);
    }
    
    return schedule;
  }

  /// Get vaccination completion percentage
  static double getCompletionPercentage(int ageInMonths, Set<String> givenVaccineIds) {
    final dueVaccines = vaccines
        .where((vaccine) => 
            vaccine.recommendedAgeMonths <= ageInMonths &&
            vaccine.isMandatory)
        .toList();
    
    if (dueVaccines.isEmpty) return 100.0;
    
    final givenCount = dueVaccines
        .where((vaccine) => givenVaccineIds.contains(vaccine.id))
        .length;
    
    return (givenCount / dueVaccines.length) * 100;
  }

  /// Get next vaccination milestone
  static Vaccine? getNextMilestone(int ageInMonths, Set<String> givenVaccineIds) {
    final upcomingVaccines = vaccines
        .where((vaccine) => 
            !givenVaccineIds.contains(vaccine.id) &&
            vaccine.recommendedAgeMonths > ageInMonths)
        .toList();
    
    if (upcomingVaccines.isEmpty) return null;
    
    upcomingVaccines.sort((a, b) => a.recommendedAgeMonths.compareTo(b.recommendedAgeMonths));
    return upcomingVaccines.first;
  }

  static String _getAgeGroupForMonths(int months) {
    if (months == 0) return 'Birth';
    if (months <= 6) return '$months Month${months > 1 ? 's' : ''}';
    if (months < 12) return '$months Months';
    if (months == 12) return '1 Year';
    if (months < 24) return '${months} Months';
    if (months < 60) return '${months ~/ 12} Year${months ~/ 12 > 1 ? 's' : ''}';
    return 'School Entry';
  }

  /// Common vaccination side effects information
  static const Map<String, List<String>> commonSideEffects = {
    'bcg_birth': [
      'Small red bump at injection site',
      'Mild swelling',
      'Scarring (normal)',
    ],
    'hepatitis_b_birth': [
      'Mild soreness at injection site',
      'Low-grade fever',
      'Tiredness',
    ],
    'pentavalent_1': [
      'Redness and swelling at injection site',
      'Mild fever',
      'Fussiness',
      'Decreased appetite',
    ],
    'mmr_1': [
      'Mild rash',
      'Fever 7-12 days after vaccination',
      'Mild swelling of glands',
    ],
    'opv_1': [
      'No common side effects (oral vaccine)',
    ],
  };

  /// Vaccination contraindications
  static const Map<String, List<String>> contraindications = {
    'general': [
      'High fever or acute illness',
      'Severe allergic reaction to previous dose',
      'Immunodeficiency disorders',
    ],
    'mmr_1': [
      'Pregnancy (for mothers)',
      'Severe immunodeficiency',
      'Recent blood transfusion',
    ],
    'bcg_birth': [
      'Immunodeficiency',
      'Active tuberculosis',
      'Severe skin conditions',
    ],
  };
}