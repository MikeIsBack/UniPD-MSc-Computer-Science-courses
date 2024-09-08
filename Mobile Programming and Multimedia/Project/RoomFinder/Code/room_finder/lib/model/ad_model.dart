/// [AdData] is the object that encapsulate all the elements that characterize a rental proposal
///
/// *[uid] the ad id
///
/// *[hostUid] the id of the host who manages the facility
///
/// *[name] of the facility
///
/// *[address] of the facility
///
/// *[rooms]
///
/// *[rentersCapacity] the maximum number of renters for the facility
///
/// *[renters] the details of each current renter
///
/// *[services] all the services the facility offers
///
/// *[monthlyRent] the montly rent
///
/// *[photosURLs] a gallery of facility's photos
class AdData {
  final String? uid;
  // host data
  final String hostUid;
  final String hostName;
  final String hostPhotoURL;
  // ad data
  final String name;
  final Address address;
  final List<Room> rooms;
  final int rentersCapacity;
  final List<Renter> renters;
  final List<String> services;
  final int monthlyRent;
  final List<String>? photosURLs;

  AdData({
    this.uid = '',
    required this.hostUid,
    required this.hostName,
    required this.hostPhotoURL,
    required this.name,
    required this.address,
    required this.rooms,
    required this.rentersCapacity,
    required this.renters,
    required this.services,
    required this.monthlyRent,
    this.photosURLs,
  });
}

/// [Address] is the object that encapsulate a facility complete address
///
/// *[street] represent the street of a facility (e.g., Via Roma 12)
///
/// *[city] represent the facility city (e.g., Padova)
class Address {
  final String street;
  final String city;

  Address({
    required this.street,
    required this.city,
  });
}

/// [Room] is the object that encapsulate a facility room
///
/// *[name] represent the room's name
///
/// *[quantity] represent the number of the same room present in the facility
class Room {
  final String name;
  int quantity;

  Room({
    required this.name,
    required this.quantity,
  });
}

/// [Bedroom] is the object that encapsulate the facility bedrooms
///
/// *[numBeds] represent the number of beds for each bedroom.
/// The list length is the total number of bedrooms while the value indexed by each list element is the number of beds for that bedroom.
class Bedroom extends Room {
  final List<int> numBeds;

  Bedroom(
      {required super.name, required super.quantity, required this.numBeds});
}

/// [Renter] is the object that encapsulate a facility current renter
///
/// *[name] represent the renter's name
///
/// *[age] represent the renter's age
///
/// *[facultyOfStudies] represent the renter's current studies
///
/// *[interests] represent the renter's interests (e.g., Cinema, Sport, etc.)
///
/// *[contractDeadline] represent the renter's current contract deadline
class Renter {
  final String name;
  final int age;
  final String facultyOfStudies;
  final String interests;
  final DateTime contractDeadline;

  Renter({
    required this.name,
    required this.age,
    required this.facultyOfStudies,
    required this.interests,
    required this.contractDeadline,
  });
}
