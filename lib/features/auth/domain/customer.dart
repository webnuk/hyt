import '../../../core/utils/json_parsing.dart';

/// Maps to the `customers` table shape returned by
/// CustomerApiController (register/login/profile).
///
/// Note: the API's `full_name` field is the one that's actually populated —
/// `name` shows up null in some responses (the customers table has no
/// `name` column, only first_name/last_name/full_name).
class Customer {
  const Customer({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.country,
    this.discount = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: parseInt(json['id']),
      email: json['email']?.toString() ?? '',
      fullName: (json['full_name'] ?? json['name'])?.toString(),
      phone: json['phone']?.toString(),
      country: json['country']?.toString(),
      discount: parseDouble(json['discount']),
    );
  }

  final int id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? country;
  final double discount;

  String get displayName => (fullName?.trim().isNotEmpty ?? false) ? fullName! : email;
}
