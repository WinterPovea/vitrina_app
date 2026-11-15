class Organization {
  const Organization({
    required this.id,
    required this.name,
    this.tagline,
    this.logoUrl,
    this.whatsapp,
    this.currency = 'USD',
    this.timezone = 'America/Guayaquil',
  });

  final String id;
  final String name;
  final String? tagline;
  final String? logoUrl;
  final String? whatsapp;
  final String currency;
  final String timezone;
}
