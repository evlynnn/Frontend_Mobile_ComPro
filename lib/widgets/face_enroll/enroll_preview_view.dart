import 'dart:convert';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class EnrollPreviewView extends StatelessWidget {
  final List<String> capturedImages;
  final TextEditingController nameController;
  final String selectedRole;
  final List<String> roles;
  final bool isAddSampleMode;
  final String? existingUserName;
  final VoidCallback onRetake;
  final VoidCallback onSubmit;
  final ValueChanged<String> onRoleChanged;

  const EnrollPreviewView({
    super.key,
    required this.capturedImages,
    required this.nameController,
    required this.selectedRole,
    required this.roles,
    required this.isAddSampleMode,
    required this.existingUserName,
    required this.onRetake,
    required this.onSubmit,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Captured images preview
          Text(
            'Captured Photos',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: capturedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final base64Image = entry.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary(context),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(base64Image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetake,
            icon: Icon(Icons.refresh, color: AppColors.primary(context)),
            label: Text(
              'Retake Photos',
              style: TextStyle(color: AppColors.primary(context)),
            ),
          ),

          const SizedBox(height: 24),

          // User info form (only for new enrollment)
          if (!isAddSampleMode) ...[
            Text(
              'User Information',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Name field
            TextField(
              controller: nameController,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                hintText: 'Enter user name',
                hintStyle: TextStyle(color: AppColors.disabled(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Role dropdown
            DropdownButtonFormField<String>(
              value: selectedRole,
              dropdownColor: AppColors.surface(context),
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                filled: true,
                fillColor: AppColors.surface(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onRoleChanged(value);
                }
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Adding sample for: $existingUserName',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColorsLight.stroke,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isAddSampleMode ? 'Add Sample' : 'Enroll User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
