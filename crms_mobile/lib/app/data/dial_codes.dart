/// Static dial-code reference data for the new-case phone field.
/// Port of the subset of CRMS/wwwroot/js/countries.js most relevant to the
/// hospital's patients. Jordan (+962) is the default.
class DialCode {
  final String iso;
  final String name;
  final String dialCode;

  const DialCode({required this.iso, required this.name, required this.dialCode});
}

const String kDefaultDialCode = '+962';

const List<DialCode> kDialCodes = [
  DialCode(iso: 'JO', name: 'Jordan', dialCode: '+962'),
  DialCode(iso: 'YE', name: 'Yemen', dialCode: '+967'),
  DialCode(iso: 'SA', name: 'Saudi Arabia', dialCode: '+966'),
  DialCode(iso: 'AE', name: 'United Arab Emirates', dialCode: '+971'),
  DialCode(iso: 'KW', name: 'Kuwait', dialCode: '+965'),
  DialCode(iso: 'QA', name: 'Qatar', dialCode: '+974'),
  DialCode(iso: 'BH', name: 'Bahrain', dialCode: '+973'),
  DialCode(iso: 'OM', name: 'Oman', dialCode: '+968'),
  DialCode(iso: 'LB', name: 'Lebanon', dialCode: '+961'),
  DialCode(iso: 'SY', name: 'Syria', dialCode: '+963'),
  DialCode(iso: 'IQ', name: 'Iraq', dialCode: '+964'),
  DialCode(iso: 'PS', name: 'Palestine', dialCode: '+970'),
  DialCode(iso: 'EG', name: 'Egypt', dialCode: '+20'),
  DialCode(iso: 'SD', name: 'Sudan', dialCode: '+249'),
  DialCode(iso: 'LY', name: 'Libya', dialCode: '+218'),
  DialCode(iso: 'TN', name: 'Tunisia', dialCode: '+216'),
  DialCode(iso: 'DZ', name: 'Algeria', dialCode: '+213'),
  DialCode(iso: 'MA', name: 'Morocco', dialCode: '+212'),
  DialCode(iso: 'US', name: 'United States', dialCode: '+1'),
  DialCode(iso: 'GB', name: 'United Kingdom', dialCode: '+44'),
  DialCode(iso: 'FR', name: 'France', dialCode: '+33'),
  DialCode(iso: 'DE', name: 'Germany', dialCode: '+49'),
  DialCode(iso: 'TR', name: 'Türkiye', dialCode: '+90'),
];

/// Mirrors formatPhone() in api.js — Jordanian numbers display without the
/// country code and with a leading zero; everything else shows "+code number".
String formatPhone(String countryCode, String number) {
  if (countryCode == kDefaultDialCode) {
    return number.startsWith('0') ? number : '0$number';
  }
  return '$countryCode $number';
}
