import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timato/ui/basics.dart';

class Settings extends StatefulWidget {
  final tomatoColor = Color.fromRGBO(255, 99, 71, 1);
  final SharedPreferences _pref;

  Settings(this._pref);
  @override
  _SettingsState createState() => _SettingsState(_pref);
}

class _SettingsState extends State<Settings> {
  _SettingsState(this._pref);
  final SharedPreferences _pref;
  @override
  Widget build(BuildContext context) {
    int timerLength, relaxLength;

    timerLength = _pref.getInt('timerLength') ?? 0;
    relaxLength = _pref.getInt('relaxLength') ?? 0;

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
              TimatoLocalization.instance.getTranslatedValue('timer_duration'),
              timerLength,
              (val) => timerLength = val * 60),
          TextSetting(
              TimatoLocalization.instance.getTranslatedValue('relax_time'),
              relaxLength,
              (val) => relaxLength = val * 60),
          _language(),
          Divider(color: Colors.grey[400]),
        ],
      ),
      floatingActionButton: FloatingRaisedButton(
          TimatoLocalization.instance.getTranslatedValue('done'), () {
        _pref.setInt('timerLength', timerLength);
        _pref.setInt('relaxLength', relaxLength);
        Navigator.pop(context, true);
      }),
    );
  }

  void _changeLanguage(String lang) {
    Language language = Language.stringlanguage[lang];
    TimatoLocalization.instance.setLocale(language.languageCode).then((data) {
      _pref.setString('language', language.languageCode);
      setState(() {});
    });
  }

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
                value:
                    Language.localeString[TimatoLocalization.instance.locale],
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
                }).toList())
          ],
        ));
  }
}

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
                    hintText: TimatoLocalization.instance
                            .getTranslatedValue('current') +
                        '${_value ~/ 60}' +
                        TimatoLocalization.instance
                            .getTranslatedValue('minutes')),
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