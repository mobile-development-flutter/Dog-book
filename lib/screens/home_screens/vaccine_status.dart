// screens/home_screens/vaccine_status.dart
import 'package:dog_book/components/add_vacine_form.dart';
import 'package:dog_book/components/custom_appbar2.dart';
import 'package:dog_book/components/custom_drawer.dart';
import 'package:dog_book/components/vaccine_card.dart';
import 'package:dog_book/model/vaccine_model.dart';
import 'package:dog_book/services/vaccine_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VaccinationStatusScreen extends StatefulWidget {
  final String petId;

  const VaccinationStatusScreen({super.key, required this.petId});

  @override
  State<VaccinationStatusScreen> createState() =>
      _VaccinationStatusScreenState();
}

class _VaccinationStatusScreenState extends State<VaccinationStatusScreen> {
  late final VaccineService _vaccineService;
  List<Vaccine> _vaccines = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _vaccineService = VaccineService();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vaccines = await _vaccineService.getVaccines(widget.petId);
      setState(() {
        _vaccines = vaccines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load vaccinations: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addVaccine(Map<String, dynamic> vaccineData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final vaccine = Vaccine(
        petId: widget.petId,
        ownerId: user.uid,
        vaccine: vaccineData['vaccine'],
        vaccinatedDate: vaccineData['vaccinatedDate'],
        vet: vaccineData['vet'],
        status: vaccineData['status'],
        nextVaccinationDate: vaccineData['nextVaccinationDate'],
        createdAt: DateTime.now(),
      );

      await _vaccineService.addVaccine(vaccine);
      await _loadVaccines(); // Refresh the list after adding
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vaccine: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteVaccine(String id) async {
    try {
      await _vaccineService.deleteVaccine(id);
      await _loadVaccines(); // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vaccine: ${e.toString()}')),
      );
    }
  }

  void _showAddVaccineForm() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: AddVaccineForm(onSubmit: _addVaccine, petName: widget.petId),
          ),
    ).then((_) => _loadVaccines()); // Refresh when dialog closes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar2(
        title: "Pet Plus",
        showBackButton: true,
        onNotificationPressed: () {
          context.go('/notification');
        },
      ),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF38B6FF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddVaccineForm,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: GoogleFonts.raleway(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVaccines,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_vaccines.isEmpty) {
      return Center(
        child: Text(
          "No vaccinations recorded yet",
          style: GoogleFonts.raleway(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVaccines,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vaccines.length,
        itemBuilder: (context, index) {
          final vaccine = _vaccines[index];
          return VaccineCard(
            vaccine: vaccine.vaccine,
            vaccinatedDate: vaccine.vaccinatedDate,
            vet: vaccine.vet,
            status: vaccine.status,
            nextVaccinationDate: vaccine.nextVaccinationDate,
            onDelete: () => _deleteVaccine(vaccine.id!),
          );
        },
      ),
    );
  }
}
