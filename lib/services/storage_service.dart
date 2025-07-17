// services/storage_service.dart
import 'dart:convert';
import 'package:dog_book/model/next_vaccine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _petsKey = 'pets';

  // Save pets list to SharedPreferences
  Future<void> savePets(List<NextVaccine> nextVaccines) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> petsJsonList =
        nextVaccines
            .map((nextVaccine) => jsonEncode(nextVaccine.toJson()))
            .toList();

    await prefs.setStringList(_petsKey, petsJsonList);
  }

  // Get pets list from SharedPreferences
  Future<List<NextVaccine>> getPets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? petsJsonList = prefs.getStringList(_petsKey);

    if (petsJsonList == null || petsJsonList.isEmpty) {
      return [];
    }

    return petsJsonList
        .map((petJson) => NextVaccine.fromJson(jsonDecode(petJson)))
        .toList();
  }

  // Add a new pet
  Future<void> addPet(NextVaccine nextVaccine) async {
    final List<NextVaccine> currentPets = await getPets();
    currentPets.add(nextVaccine);
    await savePets(currentPets);
  }

  // Delete a pet
  Future<void> deletePet(String id) async {
    final List<NextVaccine> currentPets = await getPets();
    currentPets.removeWhere((nextVaccine) => nextVaccine.id == id);
    await savePets(currentPets);
  }
}
