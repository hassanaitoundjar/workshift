import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/employee.dart';
import '../../providers/database_provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _priceController.text = widget.employee!.pricePerDay.toString();
      _phoneController.text = widget.employee!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    final employee = Employee(
      id: widget.employee?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      pricePerDay: double.parse(_priceController.text.trim()),
      createdAt: widget.employee?.createdAt ?? DateTime.now(),
    );

    if (widget.employee == null) {
      await dbProvider.addEmployee(employee);
    } else {
      await dbProvider.updateEmployee(employee);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? l10n.addEmployee : l10n.editEmployee),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveEmployee),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            Text(
              l10n.employeeName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.enterFullName,
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterEmployeeName;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Price Per Day Field
            Text(
              l10n.pricePerDay,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                hintText: l10n.enterDailyRate,
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: l10n.perDay,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterPricePerDay;
                }
                final price = double.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return l10n.pleaseEnterValidPrice;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Phone Field (Optional)
            Text(
              l10n.phoneNumberOptional,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: l10n.enterPhoneNumber,
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),

            // Save Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : _saveEmployee,
                  child: Center(
                    child: Text(
                      widget.employee == null
                          ? l10n.addEmployee
                          : l10n.updateEmployee,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Text
            Center(
              child: Text(
                l10n.allFieldsMarkedRequired,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
