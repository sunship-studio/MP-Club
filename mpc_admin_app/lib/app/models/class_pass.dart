/// A pass somebody holds, as the admin app sees it.
///
/// Deliberately has no token field: the server never sends one to this screen.
/// A token is a bearer credential and an admin list gets screenshotted, so a
/// holder is put back onto their pass with "resend link" instead.
class ClassPass {
  final String id;
  final String firstName;
  final String? lastName;
  final String email;
  final String productName;
  final int months;
  final int pricePaidCents;
  final String validFromDate;
  final String validUntilDate;
  final bool grantedByAdmin;

  /// Whether the pass was sold as a recurring membership (D17). A one-off pass
  /// has no renewal state at all.
  final bool recurring;

  /// Whether it is still set to renew. Mirrors Stripe; Stripe is the truth.
  final bool autoRenew;

  /// 'active', 'canceling' or 'canceled' — null on a one-off pass.
  final String? subscriptionStatus;

  /// When the next charge falls due. Null once it is no longer renewing.
  final String? nextChargeDate;

  /// 'active', 'expired' or 'revoked' — computed server-side against the
  /// venue's own date, so the app never has to reason about time zones.
  final String status;

  const ClassPass({
    required this.id,
    required this.firstName,
    required this.email,
    required this.productName,
    required this.months,
    required this.pricePaidCents,
    required this.validFromDate,
    required this.validUntilDate,
    required this.status,
    required this.grantedByAdmin,
    this.lastName,
    this.recurring = false,
    this.autoRenew = false,
    this.subscriptionStatus,
    this.nextChargeDate,
  });

  bool get isActive => status == 'active';
  bool get isRevoked => status == 'revoked';

  /// Still being charged for. This is the state that costs the club money if
  /// it is wrong, so it is named for the money rather than for the flag.
  bool get isBillingRecurring => recurring && autoRenew;

  String get billingLabel {
    if (!recurring) return 'One-off';
    if (subscriptionStatus == 'canceled') return 'Recurring — ended';
    if (!autoRenew) return 'Recurring — stopping';
    return nextChargeDate == null
        ? 'Recurring'
        : 'Renews $nextChargeDate';
  }

  String get fullName =>
      (lastName == null || lastName!.isEmpty) ? firstName : '$firstName $lastName';

  String get priceLabel => '€${(pricePaidCents / 100).toStringAsFixed(0)}';

  factory ClassPass.fromJson(Map<String, dynamic> json) {
    return ClassPass(
      id: json['_id'].toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'] ?? '',
      productName: json['productName'] ?? '',
      months: json['months'] ?? 0,
      pricePaidCents: json['pricePaidCents'] ?? 0,
      validFromDate: json['validFromDate'] ?? '',
      validUntilDate: json['validUntilDate'] ?? '',
      status: json['status'] ?? 'active',
      grantedByAdmin: json['grantedByAdmin'] ?? false,
      recurring: json['recurring'] ?? false,
      autoRenew: json['autoRenew'] ?? false,
      subscriptionStatus: json['subscriptionStatus'],
      nextChargeDate: json['nextChargeDate'],
    );
  }
}

/// A pass that can be granted.
class ClassPassProduct {
  final String id;
  final String name;
  final int months;
  final int priceCents;

  const ClassPassProduct({
    required this.id,
    required this.name,
    required this.months,
    required this.priceCents,
  });

  factory ClassPassProduct.fromJson(Map<String, dynamic> json) {
    return ClassPassProduct(
      id: json['_id'].toString(),
      name: json['name'] ?? '',
      months: json['months'] ?? 0,
      priceCents: json['priceCents'] ?? 0,
    );
  }
}
