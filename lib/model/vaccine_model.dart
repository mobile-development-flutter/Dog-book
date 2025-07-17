// model/vaccine_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccine {
  final String? id;
  final String petId;
  final String ownerId;
  final String vaccine;
  final String vaccinatedDate;
  final String vet;
  final String status;
  final String? nextVaccinationDate;
  final DateTime createdAt;
 

  Vaccine({
    this.id,
    required this.petId,
    required this.ownerId,
    required this.vaccine,
    required this.vaccinatedDate,
    required this.vet,
    required this.status,
    this.nextVaccinationDate,
    required this.createdAt,
    
  });

  factory Vaccine.fromMap(Map<String, dynamic> data, String id) {
    return Vaccine(
      id: id,
      petId: data['petId'] ?? '',
     
      ownerId: data['ownerId'] ?? '',
      vaccine: data['vaccine'] ?? '',
      vaccinatedDate: data['vaccinatedDate'] ?? '',
      vet: data['vet'] ?? '',
      status: data['status'] ?? '',
      nextVaccinationDate: data['nextVaccinationDate'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'vaccine': vaccine,
    
      'vaccinatedDate': vaccinatedDate,
      'vet': vet,
      'status': status,
      'nextVaccinationDate': nextVaccinationDate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}