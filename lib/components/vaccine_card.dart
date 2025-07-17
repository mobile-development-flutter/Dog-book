// components/vaccine_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VaccineCard extends StatelessWidget {
  final String vaccine;
  final String vaccinatedDate;
  final String vet;
  final String status;
  final String? nextVaccinationDate;
  final VoidCallback? onDelete;

  const VaccineCard({
    super.key,
    required this.vaccine,
    required this.vaccinatedDate,
    required this.vet,
    required this.status,
    this.nextVaccinationDate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
  
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              _buildDetailRow('Vaccined Date : ', vaccinatedDate),
              _buildDetailRow('Vaccinations Used : ', vaccine),
              _buildDetailRow('Veterinary Surgeon : ', vet),
              _buildDetailRow('Status : ', status),
              if (nextVaccinationDate != null &&
                  nextVaccinationDate!.isNotEmpty)
                _buildDetailRow('Next Date :', nextVaccinationDate!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.raleway(fontSize: 14.sp, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
