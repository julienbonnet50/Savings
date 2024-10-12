/// A placeholder class that represents an entity or model.
class Saving {

  final int id;
  final String name;
  final int companyId;
  final int accountTypeId;
  final double growthRatio;
  final double currency;
  final String startDate;

  const Saving({required this.id, required this.name, required this.companyId, required this.accountTypeId, required this.growthRatio, required this.currency, required this.startDate});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyId': companyId,
      'accountTypeId': accountTypeId,
      'growthRatio': growthRatio,
      'currency': currency,
      'startDate': startDate
    };
  }

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'],
      name: json['name'],
      companyId: json['companyId'],
      accountTypeId: json['accountTypeId'],
      growthRatio: json['growthRatio'],
      currency: json['currency'],
      startDate: json['startDate']
    );
  }
  
}
