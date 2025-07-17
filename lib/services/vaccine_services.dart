// services/vaccine_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_book/model/vaccine_model.dart';

class VaccineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vaccine>> getVaccines(String petId) async {
    final snapshot =
        await _firestore
            .collection('vaccinations')
            .where('petId', isEqualTo: petId)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => Vaccine.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addVaccine(Vaccine vaccine) async {
    await _firestore.collection('vaccinations').add(vaccine.toMap());
  }

  Future<void> deleteVaccine(String id) async {
    await _firestore.collection('vaccinations').doc(id).delete();
  }
}
