import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common_widgets.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = AppConstants.complaintCategories.first;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (img != null && mounted) {
      context.read<ComplaintProvider>().pickImage(img);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cp = context.read<ComplaintProvider>();
    final auth = context.read<AuthProvider>();
    final student = auth.student;
    final ok = await cp.raiseComplaint(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      studentId: student?.id ?? '',
      studentName: student?.name ?? '',
      department: student?.department ?? '',
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(cp.error ?? 'Failed to submit'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<ComplaintProvider>();
    return Scaffold(
      appBar: const GradientAppBar(title: 'Raise Complaint'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.complaintCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = AppConstants.complaintCategories[i];
                    final selected = cat == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : Colors.grey[300]!),
                        ),
                        child: Text(cat,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Complaint Title',
                hint: 'Brief title of your complaint',
                controller: _titleCtrl,
                prefixIcon: Icons.title_rounded,
                validator: (v) => v!.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Describe your complaint in detail...',
                controller: _descCtrl,
                maxLines: 5,
                prefixIcon: Icons.description_outlined,
                validator: (v) =>
                    v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              const Text('Attach Image (Optional)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: cp.pickedImage != null
                            ? AppTheme.primary
                            : Colors.grey[300]!),
                  ),
                  child: cp.pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.file(
                              File(cp.pickedImage!.path),
                              fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Tap to upload image',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                text: 'Submit Complaint',
                loading: cp.loading,
                onTap: _submit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
