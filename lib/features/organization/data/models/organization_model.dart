import '../../domain/entities/organization.dart';

class OrganizationModel extends Organization {
  OrganizationModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] as String,
          name: json['name'] as String,
          tagline: json['tagline'] as String?,
          logoUrl: json['logo_url'] as String?,
          whatsapp: json['whatsapp'] as String?,
          currency: (json['currency'] as String?) ?? 'USD',
          timezone: (json['timezone'] as String?) ?? 'America/Guayaquil',
        );
}
