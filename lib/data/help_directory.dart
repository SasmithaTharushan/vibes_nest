/// Verified Sri Lankan mental health and support services.
///
/// Every entry was checked against the organisation's own website or an
/// official government source on [lastVerified]. Re-check numbers at least
/// every 6 months: a wrong number on a crisis line is dangerous.
library;

enum HelpCategory {
  crisis('24/7 crisis lines'),
  support('Emotional support'),
  specialised('Women & children'),
  clinical('Hospitals & clinics'),
  emergency('Emergency');

  const HelpCategory(this.title);
  final String title;
}

class HelpService {
  const HelpService({
    required this.name,
    required this.description,
    required this.category,
    required this.source,
    this.phone,
    this.phoneDisplay,
    this.whatsapp,
    this.website,
    this.hours,
    this.languages,
  });

  final String name;
  final String description;
  final HelpCategory category;

  /// Digits to dial, e.g. `1926` or `0707308308`.
  final String? phone;
  final String? phoneDisplay;

  /// International format without "+", e.g. `94767520620`.
  final String? whatsapp;
  final String? website;
  final String? hours;
  final String? languages;

  /// Where the details were verified.
  final String source;

  String? get phoneLabel => phoneDisplay ?? phone;
}

const lastVerified = '16 Nov 2026';

const helpServices = <HelpService>[
  // ---- 24/7 crisis lines ----
  HelpService(
    name: 'National Mental Health Helpline',
    description: 'Run by the National Institute of Mental Health. Free and confidential.',
    category: HelpCategory.crisis,
    phone: '1926',
    hours: '24/7 · call or SMS',
    source: 'nimh.health.gov.lk',
  ),
  HelpService(
    name: 'CCCline',
    description: 'Free, confidential crisis support from any phone in Sri Lanka.',
    category: HelpCategory.crisis,
    phone: '1333',
    hours: '24/7',
    languages: 'Sinhala, Tamil, English',
    website: 'https://1333.lk',
    source: '1333.lk',
  ),
  HelpService(
    name: 'Lanka Life Line 1375',
    description: 'Confidential emotional and mental health support. Also on WhatsApp.',
    category: HelpCategory.crisis,
    phone: '1375',
    whatsapp: '94707112112',
    hours: '24/7',
    languages: 'Sinhala, Tamil, English',
    website: 'https://life1375.lk',
    source: 'life1375.lk',
  ),

  // ---- Emotional support ----
  HelpService(
    name: 'Sri Lanka Sumithrayo',
    description: 'Free, anonymous befriending for anyone who feels lonely, '
        'depressed or in despair.',
    category: HelpCategory.support,
    phone: '0707308308',
    phoneDisplay: '0707 308 308',
    whatsapp: '94767520620',
    hours: 'Centres open roughly 9am–4pm',
    website: 'https://srilankasumithrayo.lk',
    source: 'srilankasumithrayo.lk',
  ),

  // ---- Women & children ----
  HelpService(
    name: 'Women In Need (WIN)',
    description: 'Counselling, legal aid and shelters for women and children '
        'facing violence.',
    category: HelpCategory.specialised,
    phone: '0775676555',
    phoneDisplay: '077 567 6555',
    hours: '24-hour hotline',
    website: 'https://winsl.net',
    source: 'winsl.net',
  ),
  HelpService(
    name: "Women's Helpline 1938",
    description: 'Government helpline from the Ministry of Women and Child Affairs.',
    category: HelpCategory.specialised,
    phone: '1938',
    source: 'childwomenmin.gov.lk',
  ),
  HelpService(
    name: 'Child Helpline 1929',
    description: 'National Child Protection Authority. Report abuse or get help for a child.',
    category: HelpCategory.specialised,
    phone: '1929',
    hours: '24/7',
    languages: 'Sinhala, Tamil, English',
    website: 'https://childprotection.gov.lk',
    source: 'childprotection.gov.lk',
  ),

  // ---- Hospitals & clinics ----
  HelpService(
    name: 'National Institute of Mental Health (NIMH)',
    description: 'National psychiatric hospital in Angoda / Mulleriyawa. '
        'Ask about outpatient clinics.',
    category: HelpCategory.clinical,
    phone: '0112578234',
    phoneDisplay: '011 257 8234',
    website: 'https://nimh.health.gov.lk',
    source: 'nimh.health.gov.lk',
  ),

  // ---- Emergency ----
  HelpService(
    name: 'Suwa Seriya Ambulance',
    description: 'Free emergency ambulance service.',
    category: HelpCategory.emergency,
    phone: '1990',
    hours: '24/7',
    source: '1990.lk',
  ),
  HelpService(
    name: 'Police Emergency',
    description: 'If you or someone else is in immediate danger.',
    category: HelpCategory.emergency,
    phone: '119',
    hours: '24/7',
    source: 'police.lk',
  ),
];

/// Lines shown on the "Get help now" crisis screen, in order.
List<HelpService> get crisisLines => [
      ...helpServices.where((s) => s.category == HelpCategory.crisis),
      helpServices.firstWhere((s) => s.name == 'Sri Lanka Sumithrayo'),
      ...helpServices.where((s) => s.category == HelpCategory.emergency),
    ];
