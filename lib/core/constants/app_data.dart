/// App data constants
class AppData {
  // Blood Groups
  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  // Genders
  static const List<String> genders = ['Male', 'Female'];

  // Location Data - Governorates and Cities
  static const Map<String, List<String>> governateCityMap = {
    // Lower Egypt, Canal, and Sinai Governorates
    'Cairo': [
      'Shubra',
      'Helwan',
      'Maadi',
      'Nozha',
      'Nasr City',
      'Heliopolis',
      'Zamalek',
    ],
    'Giza': [
      'Imbaba',
      'Sheikh Zayed',
      '6th of October',
      'Faisal',
      'Dokki',
      'Mohandessin',
    ],
    'Alexandria': [
      'El Montazah',
      'El Raml',
      'El Amereya',
      'Borg El Arab',
      'Sidi Gaber',
    ],
    'Qalyubia': [
      'Benha',
      'Shubra El Kheima',
      'Qalyub',
      'El Khanka',
      'El Obour',
    ],
    'Menoufia': ['Shibin El Kom', 'Sadat City', 'Menouf', 'Ashmoun'],
    'Gharbia': ['Tanta', 'El Mahalla El Kubra', 'Kafr El Zayat', 'Zifta'],
    'Sharqia': ['Zagazig', 'Bilbeis', '10th of Ramadan', 'Faqous'],
    'Dakahlia': ['Mansoura', 'Mit Ghamr', 'Sinbillawin', 'Belqas'],
    'Damietta': ['New Damietta', 'Kafr Saad', 'Fareskour', 'Ras El Bar'],
    'Kafr El Sheikh': ['Kafr El Sheikh', 'Desouq', 'Fowa', 'Metoubes'],
    'Beheira': ['Damanhour', 'Kafr El Dawwar', 'Idku', 'Rosetta'],
    'Port Said': ['Port Said', 'Port Fouad'],
    'Ismailia': ['Ismailia', 'El Tel El Kebir', 'Fayed'],
    'Suez': ['El Arbein', 'Ataka', 'Faisal', 'Suez City'],
    'North Sinai': ['Arish', 'Bir al-Abed', 'Sheikh Zuweid', 'Rafah'],
    'South Sinai': ['Sharm El Sheikh', 'Dahab', 'Nuweiba', 'Taba', 'Tor Sinai'],

    // Upper Egypt Governorates
    'Fayoum': ['Fayoum', 'Senouris', 'Itsa', 'Tamiya'],
    'Beni Suef': ['Beni Suef', 'Ehnasya', 'Al Wasta', 'Sumusta'],
    'Minya': ['Minya', 'Malawi', 'Abu Qurqas', 'Maghagha'],
    'Assiut': ['Assiut', 'Dayrut', 'El Qusiya', 'Manfalut'],
    'Sohag': ['Sohag', 'Akhmim', 'Girga', 'El Balyana'],
    'Qena': ['Qena', 'Qift', 'Nag Hammadi', 'Qus'],
    'Luxor': ['Luxor', 'Al Qarna', 'Armant', 'Esna'],
    'Aswan': ['Aswan', 'Kom Ombo', 'Edfu', 'Daraw'],

    // Border and Desert Governorates
    'New Valley': ['El Kharga', 'Dakhla', 'Farafra', 'Baris'],
    'Matrouh': ['Marsa Matrouh', 'Sallum', 'Siwa', 'Dabaa'],
    'Red Sea': ['Hurghada', 'Safaga', 'El Quseir', 'Marsa Alam'],
  };

  // Get governorates list
  static List<String> get governorates => governateCityMap.keys.toList();

  // Get cities for a governorate
  static List<String> getCitiesForGovernorate(String governorate) {
    return governateCityMap[governorate] ?? [];
  }
}
