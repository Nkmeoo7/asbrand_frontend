/// User KYC model matching backend UserKyc schema
class UserKyc {
  final String id;
  final String userId;
  final String fullName;
  final DateTime dateOfBirth;
  final String? gender;
  final String? panNumber;
  final String? aadhaarNumber;
  final String email;
  final String phone;
  final KycAddress? address;
  final BankDetails? bankDetails;
  final String verificationStatus;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final int? creditScore;
  final double creditLimit;
  final KycDocuments? documents;

  UserKyc({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    this.gender,
    this.panNumber,
    this.aadhaarNumber,
    required this.email,
    required this.phone,
    this.address,
    this.bankDetails,
    this.verificationStatus = 'pending',
    this.verifiedAt,
    this.rejectionReason,
    this.creditScore,
    this.creditLimit = 0,
    this.documents,
  });

  factory UserKyc.fromJson(Map<String, dynamic> json) {
    return UserKyc(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : DateTime.now(),
      gender: json['gender'],
      panNumber: json['panNumber'],
      aadhaarNumber: json['aadhaarNumber'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] != null ? KycAddress.fromJson(json['address']) : null,
      bankDetails: json['bankDetails'] != null ? BankDetails.fromJson(json['bankDetails']) : null,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      rejectionReason: json['rejectionReason'],
      creditScore: json['creditScore'],
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      documents: json['documents'] != null ? KycDocuments.fromJson(json['documents']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'panNumber': panNumber,
      'aadhaarNumber': aadhaarNumber,
      'email': email,
      'phone': phone,
      'address': address?.toJson(),
      'bankDetails': bankDetails?.toJson(),
    };
  }

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
}

class KycAddress {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;

  KycAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
  });

  factory KycAddress.fromJson(Map<String, dynamic> json) {
    return KycAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }
}

class BankDetails {
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? upiId;

  BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.upiId,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountHolderName: json['accountHolderName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      bankName: json['bankName'],
      upiId: json['upiId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'upiId': upiId,
    };
  }
}

class KycDocuments {
  final String? panCard;
  final String? aadhaarFront;
  final String? aadhaarBack;
  final String? selfie;

  KycDocuments({
    this.panCard,
    this.aadhaarFront,
    this.aadhaarBack,
    this.selfie,
  });

  factory KycDocuments.fromJson(Map<String, dynamic> json) {
    return KycDocuments(
      panCard: json['panCard'],
      aadhaarFront: json['aadhaarFront'],
      aadhaarBack: json['aadhaarBack'],
      selfie: json['selfie'],
    );
  }
}
