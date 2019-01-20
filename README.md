# crystal

Make your own Magic

## Things To Do
* Get 20-30 different English name meanings
* Get 20-30 different Korean name meanings
* Name pronunciations
* Get Korean translation for in-app copy
* Get Japanese translations for in-app copy
* Add google app id https://firebase.google.com/docs/android/setup

# Done
* Google ads
* Name and meaning Excel file generator
* Collect girl and boy names
* Add launcher icon
* Korean, Japanese and English languages

## Ideas
* Name variations 

## How to Locale
* Add new get functions in `locale/locales.dart`
* Run `flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/locale\locales.dart`
* Update values in `l10n/int_*.arb` files
* Run `flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/intl_ko.arb lib/l10n/intl_en.arb lib/l10n/intl_messages.arb lib/l10n/intl_ja.arb lib/locale/locales.dart`

## How to Icons
* Update icons in assets/launcher
* Run `flutter packages pub run flutter_launcher_icons:main`

## How to APK
* Run `flutter clean`
* Run `flutter build apk`

