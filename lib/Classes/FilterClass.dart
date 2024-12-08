class Filter {
  String searchRadius;
  String bedroomsMin;
  String bedroomsMax;
  String bathroomsMin;
  String bathroomsMax;
  String minPrice;
  String maxPrice;
  String propertyType;

  Filter({
    this.searchRadius = 'This area only',
    this.bedroomsMin = "2",
    this.bedroomsMax = "No max",
    this.bathroomsMin = "2",
    this.bathroomsMax = "No max",
    this.minPrice = "No min",
    this.maxPrice = "£600,000",
    this.propertyType = "Any",
  });

  Map<String, String> searchRadii = {
    'This area only': "0.0",
    '1/4 miles': "0.25",
    '1/2 miles': "0.5",
    '1 miles': "1",
    '3 miles': "3",
    '5 miles': "5",
    '10 miles': "10",
    '20 miles': "20",
    '30 miles': "30",
    '50 miles': "50",
  };
  Map<String, String> minPrices = {
    "No min": "0",
    "£50,000": "50000",
    "£100,000": "100000",
    "£150,000": "150000",
    "£200,000": "200000",
    "£300,000": "300000",
    "£400,000": "400000",
    "£500,000": "300000",
  };
  Map<String, String> maxPrices = {
    "No max": "999999999",
    "£50,000": "50000",
    "£100,000": "100000",
    "£150,000": "150000",
    "£200,000": "200000",
    "£300,000": "300000",
    "£400,000": "400000",
    "£500,000": "500000",
    "£600,000": "600000",
    "£700,000": "700000",
    "£800,000": "800000",
    "£1,000,000": "1000000",
    "£2,000,000": "2000000",
    "£5,000,000": "5000000",
    "£10,000,000": "10000000",
    "£15,000,000": "15000000",
  };
  Map<String, String> minBedrooms = {
    "No min": "0",
    "1": "1",
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
  };
  Map<String, String> maxBedrooms = {
    "1": "1",
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
    "6": "6",
    "7": "7",
    "No max": "100"
  };
  Map<String, String> propertyTypes = {
    "Any": "",
    "Houses": "detached%2Csemi-detached%2Cterraced",
    "Flats/Apartments": "flat",
    "Bungalow": "bungalow",
  };
}
