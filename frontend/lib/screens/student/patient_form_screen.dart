import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/data_models.dart';
import '../../services/api_service.dart';

/// Multi-step patient visit form — 8 sections with validation
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  final _formData = PatientFormData();

  // Text controllers for each field
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _religionCtrl = TextEditingController();
  final _casteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _lmpCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _respRateCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _muacCtrl = TextEditingController();
  final _headCircCtrl = TextEditingController();
  final _chestCircCtrl = TextEditingController();
  final _gravidaCtrl = TextEditingController();
  final _paraCtrl = TextEditingController();
  final _abortionCtrl = TextEditingController();
  final _stillBirthCtrl = TextEditingController();
  final _gestAgeCtrl = TextEditingController();

  final List<String> _stepLabels = [
    'Basic Info', 'Family History', 'Personal History', 'Female Health',
    'Vitals', 'Pediatric', 'Maternal', 'NCD Screening',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose(); _religionCtrl.dispose();
    _casteCtrl.dispose(); _addressCtrl.dispose(); _weightCtrl.dispose();
    _heightCtrl.dispose(); _phoneCtrl.dispose(); _sleepCtrl.dispose();
    _allergiesCtrl.dispose(); _lmpCtrl.dispose(); _systolicCtrl.dispose();
    _diastolicCtrl.dispose(); _heartRateCtrl.dispose(); _respRateCtrl.dispose();
    _pulseCtrl.dispose(); _sugarCtrl.dispose(); _muacCtrl.dispose();
    _headCircCtrl.dispose(); _chestCircCtrl.dispose(); _gravidaCtrl.dispose();
    _paraCtrl.dispose(); _abortionCtrl.dispose(); _stillBirthCtrl.dispose();
    _gestAgeCtrl.dispose();
    super.dispose();
  }

  void _syncFormData() {
    _formData.name = _nameCtrl.text.trim();
    _formData.age = int.tryParse(_ageCtrl.text);
    _formData.religion = _religionCtrl.text.trim();
    _formData.caste = _casteCtrl.text.trim();
    _formData.address = _addressCtrl.text.trim();
    _formData.weight = double.tryParse(_weightCtrl.text);
    _formData.height = double.tryParse(_heightCtrl.text);
    _formData.patientPhone = _phoneCtrl.text.trim();
    _formData.sleepPattern = _sleepCtrl.text.trim();
    _formData.allergies = _allergiesCtrl.text.trim();
    _formData.lmp = _lmpCtrl.text.trim();
    _formData.systolic = int.tryParse(_systolicCtrl.text);
    _formData.diastolic = int.tryParse(_diastolicCtrl.text);
    _formData.heartRate = int.tryParse(_heartRateCtrl.text);
    _formData.respiratoryRate = int.tryParse(_respRateCtrl.text);
    _formData.pulseRate = int.tryParse(_pulseCtrl.text);
    _formData.bloodSugar = double.tryParse(_sugarCtrl.text);
    _formData.muac = double.tryParse(_muacCtrl.text);
    _formData.headCircumference = double.tryParse(_headCircCtrl.text);
    _formData.chestCircumference = double.tryParse(_chestCircCtrl.text);
    _formData.gravida = int.tryParse(_gravidaCtrl.text);
    _formData.para = int.tryParse(_paraCtrl.text);
    _formData.abortions = int.tryParse(_abortionCtrl.text);
    _formData.stillBirths = int.tryParse(_stillBirthCtrl.text);
    _formData.gestationalAge = int.tryParse(_gestAgeCtrl.text);
  }

  bool _validateCurrentStep() {
    _syncFormData();
    switch (_currentStep) {
      case 0:
        if (_formData.name.isEmpty) {
          _showError('Patient name is required');
          return false;
        }
        if (_formData.age == null || _formData.age! <= 0 || _formData.age! > 150) {
          _showError('Please enter a valid age');
          return false;
        }
        return true;
      case 4: // Vitals
        if (_formData.systolic != null && (_formData.systolic! < 60 || _formData.systolic! > 300)) {
          _showError('Systolic BP must be between 60-300 mmHg');
          return false;
        }
        if (_formData.diastolic != null && (_formData.diastolic! < 30 || _formData.diastolic! > 200)) {
          _showError('Diastolic BP must be between 30-200 mmHg');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.alertRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Visit Form'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.charcoalText,
      ),
      body: Column(
        children: [
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(8, (i) {
                final isComplete = i < _currentStep;
                final isCurrent = i == _currentStep;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isComplete ? AppTheme.normalGreen
                          : isCurrent ? AppTheme.primaryBlue : AppTheme.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Step ${_currentStep + 1} of 8 — ${_stepLabels[_currentStep]}',
              style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(_currentStep),
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('← Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: _currentStep < 7
                      ? ElevatedButton(
                          onPressed: () {
                            if (_validateCurrentStep()) {
                              setState(() => _currentStep++);
                            }
                          },
                          child: Text('Next: ${_stepLabels[_currentStep + 1]} →'),
                        )
                      : ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.normalGreen),
                          child: _isSubmitting
                              ? const SizedBox(width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Submit Record ✓'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: return _buildBasicPersona();
      case 1: return _buildFamilyHistory();
      case 2: return _buildPersonalHistory();
      case 3: return _buildFemaleHealth();
      case 4: return _buildVitals();
      case 5: return _buildPediatric();
      case 6: return _buildMaternalHistory();
      case 7: return _buildNCDScreening();
      default: return const SizedBox();
    }
  }

  Widget _buildBasicPersona() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Persona', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person))),
        const SizedBox(height: 12),
        TextField(controller: _ageCtrl,
          decoration: const InputDecoration(labelText: 'Age *', prefixIcon: Icon(Icons.cake)),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        const Text('Sex', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(spacing: 8, children: ['Male', 'Female', 'Other'].map((s) =>
          ChoiceChip(label: Text(s), selected: _formData.sex == s,
            onSelected: (_) => setState(() => _formData.sex = s))).toList()),
        const SizedBox(height: 12),
        TextField(controller: _religionCtrl, decoration: const InputDecoration(labelText: 'Religion')),
        const SizedBox(height: 12),
        TextField(controller: _casteCtrl, decoration: const InputDecoration(labelText: 'Caste')),
        const SizedBox(height: 12),
        TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
          keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: _weightCtrl,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _syncFormData()))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _heightCtrl,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _syncFormData()))),
        ]),
        const SizedBox(height: 16),
        // Live BMI Card
        if (_formData.bmi > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.lightBlueTint, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('BMI', style: TextStyle(color: AppTheme.mutedGrey)),
                  Text(_formData.bmi.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bmiColor(_formData.bmiCategory), borderRadius: BorderRadius.circular(16)),
                  child: Text(_formData.bmiCategory, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _bmiColor(String cat) {
    switch (cat) {
      case 'Underweight': return AppTheme.cautionAmber;
      case 'Normal': return AppTheme.normalGreen;
      case 'Overweight': return AppTheme.cautionAmber;
      case 'Obese': return AppTheme.alertRed;
      default: return AppTheme.mutedGrey;
    }
  }

  Widget _buildFamilyHistory() {
    final conditions = ['Hypertension', 'Diabetes', 'Heart Disease', 'Stroke', 'Cancer', 'Tuberculosis'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Family History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select all conditions present in the patient\'s family', style: TextStyle(color: AppTheme.mutedGrey)),
        const SizedBox(height: 16),
        ...conditions.map((c) => Card(
          child: CheckboxListTile(
            title: Text(c, style: const TextStyle(fontWeight: FontWeight.w500)),
            value: _formData.familyHistory.contains(c),
            onChanged: (v) => setState(() {
              if (v == true) _formData.familyHistory.add(c);
              else _formData.familyHistory.remove(c);
            }),
          ),
        )),
      ],
    );
  }

  Widget _buildPersonalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Diet', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(spacing: 8, children: ['Vegetarian', 'Non-Veg', 'Vegan', 'Mixed'].map((s) =>
          ChoiceChip(label: Text(s), selected: _formData.diet == s,
            onSelected: (_) => setState(() => _formData.diet = s))).toList()),
        const SizedBox(height: 16),
        TextField(controller: _sleepCtrl, decoration: const InputDecoration(labelText: 'Sleep Pattern (e.g., 7-8 hours)')),
        const SizedBox(height: 12),
        const Text('Bowel Habits', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(spacing: 8, children: ['Regular', 'Irregular', 'Constipation'].map((s) =>
          ChoiceChip(label: Text(s), selected: _formData.bowelHabit == s,
            onSelected: (_) => setState(() => _formData.bowelHabit = s))).toList()),
        const SizedBox(height: 16),
        const Text('Addictions', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        Card(child: SwitchListTile(title: const Text('Smoking'), value: _formData.smoking,
          onChanged: (v) => setState(() => _formData.smoking = v), activeThumbColor: AppTheme.primaryBlue)),
        Card(child: SwitchListTile(title: const Text('Alcohol'), value: _formData.alcohol,
          onChanged: (v) => setState(() => _formData.alcohol = v), activeThumbColor: AppTheme.primaryBlue)),
        Card(child: SwitchListTile(title: const Text('Tobacco'), value: _formData.tobacco,
          onChanged: (v) => setState(() => _formData.tobacco = v), activeThumbColor: AppTheme.primaryBlue)),
        const SizedBox(height: 12),
        TextField(controller: _allergiesCtrl, decoration: const InputDecoration(labelText: 'Allergies')),
      ],
    );
  }

  Widget _buildFemaleHealth() {
    if (_formData.sex != 'Female') {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: AppTheme.mutedGrey),
            SizedBox(height: 12),
            Text('This section is for female patients only.',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.mutedGrey, fontSize: 16)),
            SizedBox(height: 8),
            Text('Tap "Next" to continue.', style: TextStyle(color: AppTheme.mutedGrey)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.lightBlueTint, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
            SizedBox(width: 8),
            Text('Female Health Section', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Menstrual Cycle Regularity', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(spacing: 8, children: ['Regular', 'Irregular'].map((s) =>
          ChoiceChip(label: Text(s), selected: _formData.menstrualRegularity == s,
            onSelected: (_) => setState(() => _formData.menstrualRegularity = s))).toList()),
        const SizedBox(height: 12),
        TextField(controller: _lmpCtrl,
          decoration: const InputDecoration(labelText: 'Last Menstrual Period', prefixIcon: Icon(Icons.calendar_today))),
        const SizedBox(height: 16),
        const Text('Currently Pregnant?', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('Yes'), selected: _formData.isPregnant,
            onSelected: (_) => setState(() => _formData.isPregnant = true)),
          ChoiceChip(label: const Text('No'), selected: !_formData.isPregnant,
            onSelected: (_) => setState(() => _formData.isPregnant = false)),
        ]),
      ],
    );
  }

  Widget _buildVitals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vitals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(controller: _systolicCtrl,
            decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _syncFormData()))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _diastolicCtrl,
            decoration: const InputDecoration(labelText: 'Diastolic (mmHg)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _syncFormData()))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _heartRateCtrl,
          decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _respRateCtrl,
          decoration: const InputDecoration(labelText: 'Respiratory Rate'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _pulseCtrl,
          decoration: const InputDecoration(labelText: 'Pulse Rate (bpm)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _sugarCtrl,
          decoration: const InputDecoration(labelText: 'Random Blood Sugar (mg/dL)'),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() => _syncFormData())),
        const SizedBox(height: 16),
        // Live risk indicators
        if (_formData.hypertensionRisk != 'N/A')
          _buildRiskCard('Hypertension',
            'BP: ${_systolicCtrl.text}/${_diastolicCtrl.text} mmHg', _formData.hypertensionRisk),
        if (_formData.diabetesRisk != 'N/A')
          _buildRiskCard('Diabetes Risk',
            'Sugar: ${_sugarCtrl.text} mg/dL', _formData.diabetesRisk),
      ],
    );
  }

  Widget _buildPediatric() {
    if (_formData.age != null && _formData.age! > 5) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: AppTheme.mutedGrey),
            SizedBox(height: 12),
            Text('Pediatric section is for children under 5 years.',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.mutedGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.lightBlueTint, borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.child_care, color: AppTheme.primaryBlue, size: 20),
            SizedBox(width: 8),
            Text('For children under 5 years', style: TextStyle(color: AppTheme.primaryBlue)),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Pediatric Assessment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: _muacCtrl,
          decoration: const InputDecoration(labelText: 'Mid-Arm Circumference (cm)'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _headCircCtrl,
          decoration: const InputDecoration(labelText: 'Head Circumference (cm)'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _chestCircCtrl,
          decoration: const InputDecoration(labelText: 'Chest Circumference (cm)'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        const Text('Vaccination Status', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ...['BCG', 'OPV', 'DPT', 'Measles', 'Hepatitis B', 'Vitamin A'].map((v) =>
          CheckboxListTile(title: Text(v),
            value: _formData.vaccinations.contains(v),
            onChanged: (checked) => setState(() {
              if (checked == true) _formData.vaccinations.add(v);
              else _formData.vaccinations.remove(v);
            }))),
      ],
    );
  }

  Widget _buildMaternalHistory() {
    if (_formData.sex != 'Female' || !_formData.isPregnant) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: AppTheme.mutedGrey),
            SizedBox(height: 12),
            Text('Maternal section is for pregnant patients only.',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.mutedGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Maternal History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: _gravidaCtrl,
          decoration: const InputDecoration(labelText: 'Gravida (Total Pregnancies)'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _paraCtrl,
          decoration: const InputDecoration(labelText: 'Para (Live Births)'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _abortionCtrl,
          decoration: const InputDecoration(labelText: 'Abortions'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _stillBirthCtrl,
          decoration: const InputDecoration(labelText: 'Still Births'),
          keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _gestAgeCtrl,
          decoration: const InputDecoration(labelText: 'Gestational Age (weeks)'),
          keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildNCDScreening() {
    _syncFormData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NCD Screening Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_formData.hypertensionRisk != 'N/A')
          _buildRiskCard('Hypertension',
            'BP: ${_formData.systolic ?? "-"}/${_formData.diastolic ?? "-"} mmHg', _formData.hypertensionRisk),
        if (_formData.diabetesRisk != 'N/A')
          _buildRiskCard('Diabetes Risk',
            'Blood Sugar: ${_formData.bloodSugar?.toStringAsFixed(0) ?? "-"} mg/dL', _formData.diabetesRisk),
        if (_formData.bmi > 0)
          _buildRiskCard('BMI Status',
            'BMI: ${_formData.bmi.toStringAsFixed(1)} — ${_formData.bmiCategory}',
            _formData.bmiCategory == 'Obese' ? 'high'
              : _formData.bmiCategory == 'Overweight' ? 'moderate' : 'normal'),
        const SizedBox(height: 16),
        // Overall Risk Assessment
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.riskColor(_formData.overallRisk).withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.riskColor(_formData.overallRisk)),
          ),
          child: Column(
            children: [
              const Text('Overall Risk Assessment', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                '${_formData.overallRisk.toUpperCase()} RISK',
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold,
                  color: AppTheme.riskColor(_formData.overallRisk)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard(String title, String subtitle, String risk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppTheme.riskColor(risk), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 4)],
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.mutedGrey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.riskColor(risk), borderRadius: BorderRadius.circular(16)),
          child: Text(risk[0].toUpperCase() + risk.substring(1),
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    _syncFormData();
    if (_formData.name.isEmpty) {
      _showError('Patient name is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get houseId from route arguments
      final houseId = ModalRoute.of(context)?.settings.arguments as String? ?? '';

      await ApiService.submitPatientRecord(_formData.toJson(), houseId);

      if (!mounted) return;

      // Navigate to success
      Navigator.pushNamedAndRemoveUntil(context, '/student/dashboard', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record submitted — ${_formData.overallRisk.toUpperCase()} risk detected'),
          backgroundColor: AppTheme.riskColor(_formData.overallRisk) == AppTheme.normalGreen
              ? AppTheme.normalGreen : AppTheme.cautionAmber,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
