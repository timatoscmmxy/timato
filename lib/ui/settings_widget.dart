import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timato/ui/basics.dart';

class Settings extends StatefulWidget {
  // static void setLocale(BuildContext context, Locale locale) {
  //   _SettingsState state = context.findAncestorStateOfType<_SettingsState>();
  //   state.setLocale(locale);
  // }

  final tomatoColor = Color.fromRGBO(255, 99, 71, 1);
  final SharedPreferences _pref;

  Settings(this._pref);
  @override
  _SettingsState createState() => _SettingsState(_pref);
}

class _SettingsState extends State<Settings> {
  // void setLocale(Locale locale){
  //   setState((){
  //     locale = locale;
  //   });
  // }
  _SettingsState(this._pref);
  final SharedPreferences _pref;
  @override
  Widget build(BuildContext context) {
    int timerLength, relaxLength;
    // String language;

    timerLength = _pref.getInt('timerLength') ?? 0;
    relaxLength = _pref.getInt('relaxLength') ?? 0;
    // language = _pref.getString('language') ?? 'en_US';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          TimatoLocalization.instance.getTranslatedValue("settings_title"),
          style: TextStyle(color: ConstantHelper.tomatoColor),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ConstantHelper.tomatoColor,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          TextSetting(
              TimatoLocalization.instance.getTranslatedValue('timer_duration'), timerLength, (val) => timerLength = val * 60),
          TextSetting(
              TimatoLocalization.instance.getTranslatedValue('relax_time'), relaxLength, (val) => relaxLength = val * 60),
          _language(),
          Divider(color: Colors.grey[400]),
        ],
      ),
      floatingActionButton: FloatingRaisedButton(TimatoLocalization.instance.getTranslatedValue('done'), () {
        _pref.setInt('timerLength', timerLength);
        _pref.setInt('relaxLength', relaxLength);
        Navigator.pop(context,true);
      }),
    );
  }

  void _changeLanguage(String lang) {
    Language language = Language.stringlanguage[lang];
    // Locale _temp;
    // switch(language.languageCode) {
    //   case 'en':
    //     _temp = Locale(language.languageCode);
    //     break;
    //   case 'zh':
    //     _temp = Locale(language.languageCode);
    //     break;
    //   default:
    //     _temp = Locale(language.languageCode);
    // }
    // locale = _temp;
    TimatoLocalization.instance.setLocale(language.languageCode).then((data){
      _pref.setString('language', language.languageCode);
      setState(() {});
    });
  }

  // Language _whichLang() {
  //   if(locale == Locale("en", "")){
  //     return "English" as Language;
  //   }else{
  //     return "中文" as Language;
  //   }
  // }

  Widget _language() {
    return Container(
        height: 60,
        child: new Row(
          children: <Widget>[
            SizedBox(width: 15),
            Text(
              TimatoLocalization.instance.getTranslatedValue('language'),
              style: TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 90),
            DropdownButton<String>(
                value: Language.localeString[TimatoLocalization.instance.locale],
                onChanged: (String language) {
                  _changeLanguage(language);
                },
                items: ConstantHelper.twoLanguageList.map((lang) {
                  return DropdownMenuItem<String>(
                      value: lang,
                      child: Row(children: <Widget>[
                        Text(
                          lang,
                          style: TextStyle(fontSize: 14),
                        )
                      ]));
                })
                    // <DropdownMenuItem<Language>>(
                    //       (lang) => DropdownMenuItem(
                    //           value: lang,
                    //           child: Row(
                    //             children: <Widget>[Text(lang.name)],
                    //           )),
                    //     )
                    .toList())
          ],
        ));
  }
}

// class Settings extends StatelessWidget {
//   final tomatoColor = Color.fromRGBO(255, 99, 71, 1);
//   final SharedPreferences _pref;

//   Settings(this._pref);

//   @override
//   Widget build(BuildContext context) {
//     int timerLength, relaxLength;
//     String language;

//     timerLength = _pref.getInt('timerLength') ?? 0;
//     relaxLength = _pref.getInt('relaxLength') ?? 0;
//     language = _pref.getString('language') ?? 'en_US';

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Text(
//           'Settings',
//           style: TextStyle(color: ConstantHelper.tomatoColor),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: ConstantHelper.tomatoColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: ListView(
//         children: <Widget>[
//           TextSetting(
//               'Timer Duration', timerLength, (val) => timerLength = val * 60),
//           TextSetting(
//               'Relax Time', relaxLength, (val) => relaxLength = val * 60),
//           _language(),
//           Divider(color: Colors.grey[400]),
//         ],
//       ),
//       floatingActionButton: FloatingRaisedButton('Done', () {
//         _pref.setInt('timerLength', timerLength);
//         _pref.setInt('relaxLength', relaxLength);
//         Navigator.pop(context);
//       }),
//     );
//   }

//   Widget _language() {
//     return Container(
//         height: 60,
//         child: new Row(
//           children: <Widget>[
//             SizedBox(width: 15),
//             Text(
//               "Language:",
//               style: TextStyle(
//                 fontSize: 17,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(width: 90),
//             DropdownButton<Language>(
//                 onChanged: (Language language ){
//                   setState((){

//                   });
//                 },
//                 items: Language.languageList()
//                     .map<DropdownMenuItem<Language>>(
//                       (lang) => DropdownMenuItem(
//                           value: lang,
//                           child: Row(
//                             children: <Widget>[Text(lang.name)],
//                           )),
//                     )
//                     .toList())
//           ],
//         ));
//   }
// }

// class TextSetting extends StatefulWidget {
//   final String _text;
//   final int _value;
//   final void Function(int) _onChange;

//   TextSetting(this._text, this._value, this._onChange);
//   @override
//   _TextSettingState createState() => _TextSettingState(this._text, this._value, this._onChange);
// }

// class _TextSettingState extends State<TextSetting> {
//   final String _text;
//   final int _value;
//   final void Function(int) _onChange;

//   _TextSettingState(this._text, this._value, this._onChange);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: ListTile(
//         title: Row(
//           children: <Widget>[
//             Expanded(
//               child: Container(
//                 child: Text(
//                   '$_text: ',
//                   style: TextStyle(),
//                 ),
//                 padding: EdgeInsets.all(10),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                   child: TextField(
//                 decoration: InputDecoration(
//                     hintText: TimatoLocalization.instance.getTranslatedValue('current')+'${_value ~/ 60}'+TimatoLocalization.instance.getTranslatedValue('minuets')),
//                 onChanged: (String text) {
//                   if (text == '') {
//                     return;
//                   }
//                   int val;
//                   try {
//                     val = int.parse(text);
//                   } catch (e) {
//                     TimerLengthAlert.show(context);
//                   }
//                   if (val < 0 || val > 5940) {
//                     TimerLengthAlert.show(context);
//                   }
//                   _onChange(val);
//                 },
//               )),
//             )
//           ],
//         ),
//         contentPadding: EdgeInsets.all(5),
//       ),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//           border: Border(
//               bottom: BorderSide(
//                   color: Colors.black12, style: BorderStyle.solid, width: 1))),
//     );
//   }
//   }
// }
class TextSetting extends StatelessWidget {
  final String _text;
  final int _value;
  final void Function(int) _onChange;

  TextSetting(this._text, this._value, this._onChange);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  '$_text: ',
                  style: TextStyle(),
                ),
                padding: EdgeInsets.all(10),
              ),
            ),
            Expanded(
              child: Container(
                  child: TextField(
                decoration: InputDecoration(
                    hintText: TimatoLocalization.instance.getTranslatedValue('current')+'${_value ~/ 60}'+TimatoLocalization.instance.getTranslatedValue('minutes')),
                onChanged: (String text) {
                  if (text == '') {
                    return;
                  }
                  int val;
                  try {
                    val = int.parse(text);
                  } catch (e) {
                    TimerLengthAlert.show(context);
                  }
                  if (val < 0 || val > 5940) {
                    TimerLengthAlert.show(context);
                  }
                  _onChange(val);
                },
              )),
            )
          ],
        ),
        contentPadding: EdgeInsets.all(5),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Colors.black12, style: BorderStyle.solid, width: 1))),
    );
  }
}
