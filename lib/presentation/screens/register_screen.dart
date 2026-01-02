import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../models/patient.dart';

/// Register screen - New user registration
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _familyContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String? _selectedBloodType;
  double? _weight;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _familyContactController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4DD0E1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('សូមជ្រើសរើសថ្ងៃខែឆ្នាំកំណើត'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedBloodType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('សូមជ្រើសរើសក្រុមឈាម'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Create Patient object with all data
      final patient = Patient(
        name: _nameController.text.trim(),
        tel: _phoneController.text.trim(),
        familyContact: _familyContactController.text.trim(),
        bloodtype: _selectedBloodType!,
        dateOfBirth: _selectedDateOfBirth!,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        weight: _weight,
      );

      // Register user with complete patient data and password
      await authProvider.register(
        patient: patient,
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.go('/dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4DD0E1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ចុះឈ្មោះ',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'បង្កើតគណនីថ្មី',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          label: 'ឈ្មោះពេញ',
                          hint: 'សុខជាត',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលឈ្មោះ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Date of Birth
                        InkWell(
                          onTap: _selectDateOfBirth,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'ថ្ងៃខែឆ្នាំកំណើត',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            child: Text(
                              _selectedDateOfBirth != null
                                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                  : 'ជ្រើសរើសថ្ងៃខែឆ្នាំកំណើត',
                              style: TextStyle(
                                color: _selectedDateOfBirth != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Blood Type
                        DropdownButtonFormField<String>(
                          value: _selectedBloodType,
                          decoration: InputDecoration(
                            labelText: 'ក្រុមឈាម',
                            prefixIcon: const Icon(Icons.bloodtype),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _bloodTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Phone number
                        _buildTextField(
                          controller: _phoneController,
                          label: 'លេខទូរស័ព្ទ',
                          hint: '012345678',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលលេខទូរស័ព្ទ';
                            }
                            if (value.length < 8) {
                              return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Family contact
                        _buildTextField(
                          controller: _familyContactController,
                          label: 'លេខទូរស័ព្ទគ្រួសារ',
                          hint: '098765432',
                          icon: Icons.family_restroom,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលលេខទូរស័ព្ទគ្រួសារ';
                            }
                            if (value.length < 8) {
                              return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Weight (optional)
                        _buildTextField(
                          label: 'ទម្ងន់ (kg)',
                          hint: '23.0',
                          icon: Icons.monitor_weight,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _weight = double.tryParse(value);
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Address (optional)
                        _buildTextField(
                          controller: _addressController,
                          label: 'អាសយដ្ឋាន (ស្រេចចិត្ត)',
                          hint: 'ភូមិ កុម សង្កាត់',
                          icon: Icons.location_on,
                          maxLines: 2,
                        ),

                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'ពាក្យសម្ងាត់',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                            }
                            if (value.length < 6) {
                              return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច ៦ តួ';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'បញ្ជាក់ពាក្យសម្ងាត់',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
                            }
                            if (value != _passwordController.text) {
                              return 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DD0E1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'ចុះឈ្មោះ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'មានគណនីរួចហើយ? ',
                                style: TextStyle(fontSize: 16),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.pushReplacement('/login');
                                },
                                child: const Text(
                                  'ចូលប្រើ',
                                  style: TextStyle(
                                    color: Color(0xFF4DD0E1),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
