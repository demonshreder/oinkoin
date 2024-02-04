
import 'package:deep_collection/deep_collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/records-utility-functions.dart';
import 'package:piggybank/i18n.dart';

import 'dropdown-customization-item.dart';

class CustomizationPage extends StatefulWidget {

  @override
  CustomizationPageState createState() => CustomizationPageState();
}

class CustomizationPageState extends State<CustomizationPage> {

  static String getKeyFromObject<T>(Map<String, T> originalMap, T searchValue, String defaultKey) {
    final invertedMap = originalMap.map((key, value) => MapEntry(value, key));
    return invertedMap[searchValue] ?? defaultKey;
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();

    // Get theme color
    int themeColorDropdownValueIndex = prefs.getInt('themeColor') ?? 0;
    themeColorDropdownValue = getKeyFromObject<int>(themeColorDropdownValues, themeColorDropdownValueIndex, "Default".i18n);

    // Get theme style
    int themeStyleDropdownValueIndex = prefs.getInt('themeMode') ?? 0;
    themeStyleDropdownValue = getKeyFromObject<int>(themeStyleDropdownValues, themeStyleDropdownValueIndex, "System".i18n);

    // Get languageLocale
    var userDefinedLanguageLocale = prefs.getString("languageLocale");
    if (userDefinedLanguageLocale != null ) {
      languageDropdownValue = getKeyFromObject<String>(languageToLocaleTranslation, userDefinedLanguageLocale, "System".i18n);
    }

    decimalDigitsValue = prefs.getInt('numDecimalDigits') ?? 2;
    useGroupSeparator = prefs.getBool("useGroupSeparator") ?? true;
    groupSeparatorValue = prefs.getString("groupSeparator") ?? getLocaleGroupingSeparator();
    if (!symbolsTranslations.containsKey(groupSeparatorValue)) {
      // this happen when there are languages with different group separator
      // like persian
      symbolsTranslations[groupSeparatorValue] = groupSeparatorValue;
    }
    groupSeparatorsValues.remove(getLocaleDecimalSeparator());
    overwriteDotValueWithComma = prefs.getBool("overwriteDotValueWithComma") ?? getLocaleDecimalSeparator() == ",";
  }

  late SharedPreferences prefs;

  // Style dropdown
  Map<String, int> themeStyleDropdownValues = {
    "System".i18n: 0,
    "Light".i18n: 1,
    "Dark".i18n: 2
  };
  late String themeStyleDropdownValue;

  // Theme color dropdown
  Map<String, int> themeColorDropdownValues = {
    "Default".i18n: 0,
    "System".i18n: 1,
    "Monthly Image".i18n: 2
  };
  late String themeColorDropdownValue;

  Map<String, String> languageToLocaleTranslation = {
    "System".i18n: "system",
    "Deutsch": "de_DE",
    "English": "en_US",
    "Español": "es_ES",
    "Français": "fr_FR",
    "Italiano": "it_IT",
    "Português (Brazil)": "pt_BR",
    "Português (Portugal)": "pr_PT",
    "Pусский язык": "ru_RU",
    "Türkçe": "tr_TR",
    "Veneto": "vec_IT",
    "简化字": "zh_CN",
  };
  late String languageDropdownValue;

  List<int> decimalDigitsValues = [0, 1, 2, 3, 4];
  int decimalDigitsValue = 2;

  bool useGroupSeparator = true;
  Map<String, String> symbolsTranslations = {
    ".": "dot".i18n,
    ",": "comma".i18n,
    "\u00A0": "space".i18n,
    "_": "underscore".i18n,
    "'": "apostrophe".i18n
  };
  List<String> groupSeparatorsValues = [".", ",", "\u00A0", "_", "'"];
  String groupSeparatorValue = ".";

  bool overwriteDotValueWithComma = true;

  Widget buildDecimalDigitsDropdownButton() {
    return DropdownButton<int>(
      padding: EdgeInsets.all(0),
      underline: SizedBox(),
      value: decimalDigitsValue,
      onChanged: (int? value) {
        setState(() {
          decimalDigitsValue = value!;
          prefs.setInt("numDecimalDigits", value);
        });
      },
      items: decimalDigitsValues.map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }

  Widget buildGroupingSeparatorDropdownButton() {
    return DropdownButton<String>(
      padding: EdgeInsets.all(0),
      underline: SizedBox(),
      value: groupSeparatorValue,
      onChanged: (String? value) {
        setState(() {
          groupSeparatorValue = value!;
          prefs.setString("groupSeparator", value);
          print("Selected Group Separator:" + symbolsTranslations[value]!);
        });
      },
      items: groupSeparatorsValues.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(symbolsTranslations[value]!),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customization".i18n),
      ),
      body: FutureBuilder(
        future: initializePreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  DropdownCustomizationItem(
                    title: "Colors".i18n,
                    subtitle: "Select the app theme color".i18n + " - " +  "Require App restart".i18n,
                    dropdownValues: themeColorDropdownValues,
                    selectedDropdownKey: themeColorDropdownValue,
                    sharedConfigKey: "themeColor",
                  ),
                  DropdownCustomizationItem(
                    title: "Theme style".i18n,
                    subtitle: "Select the app theme style".i18n + " - " +  "Require App restart".i18n,
                    dropdownValues: themeStyleDropdownValues,
                    selectedDropdownKey: themeStyleDropdownValue,
                    sharedConfigKey: "themeMode",
                  ),
                  DropdownCustomizationItem(
                    title: "Language".i18n,
                    subtitle: "Select the app language".i18n  + " - " +  "Require App restart".i18n,
                    dropdownValues: languageToLocaleTranslation,
                    selectedDropdownKey: languageDropdownValue,
                    sharedConfigKey: "languageLocale",
                  ),
                  ListTile(
                    trailing: buildDecimalDigitsDropdownButton(),
                    title: Text("Decimal digits".i18n),
                    subtitle: Text("Select the number of decimal digits".i18n),
                  ),
                  Visibility(
                    visible: getLocaleDecimalSeparator() == ",",
                    child: ListTile(
                      trailing: Switch(
                        // This bool value toggles the switch.
                        value: overwriteDotValueWithComma,
                        onChanged: (bool value) {
                          setState(() {
                            prefs.setBool("overwriteDotValueWithComma", value);
                            overwriteDotValueWithComma = value;
                          });
                        },
                      ),
                      title: Text("Overwrite the `dot`".i18n),
                      subtitle: Text("Overwrite `dot` with `comma`".i18n),
                    ),
                  ),
                  ListTile(
                    trailing: Switch(
                      // This bool value toggles the switch.
                      value: useGroupSeparator,
                      onChanged: (bool value) {
                        setState(() {
                          prefs.setBool("useGroupSeparator", value);
                          useGroupSeparator = value;
                        });
                      },
                    ),
                    title: Text("Use `Grouping separator`".i18n),
                    subtitle: Text("For example, 1000 -> 1,000".i18n),
                  ),
                  Visibility(
                    visible: useGroupSeparator,
                    child: ListTile(
                      trailing: buildGroupingSeparatorDropdownButton(),
                      title: Text("Grouping separator".i18n),
                      subtitle: Text("Overwrite grouping separator".i18n),
                    ),
                  )
                ],
              ),
            );
          } else {
            // Return a placeholder or loading indicator while waiting for initialization.
            return Center(
              child: CircularProgressIndicator(),
            ); // Replace with your desired loading widget.
          }
        },
      )
    );
  }
}
