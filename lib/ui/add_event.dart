import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

class AddEvent extends StatefulWidget{
  final String _textHint;
  final bool isPlanned;

  AddEvent(this._textHint, {this.isPlanned});

  @override
  AddEventState createState() => AddEventState(_textHint, isPlanned: isPlanned);

  static showAddEvent(context){
    showModalBottomSheet(
      context: context,
      builder: (_) => AddEvent('New event', isPlanned: false,),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
    );
  }

  static showAddUnplannedEvent(context){
    showModalBottomSheet(
      context: context,
      builder: (_) => AddEvent('New unplanned event', isPlanned: true,),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
    );
  }

}

// ignore: must_be_immutable
class AddEventState extends State<AddEvent>{
  final String _textHint;
  final bool isPlanned;

  AddEventState(this._textHint, {this.isPlanned});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:18 ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              child: TextField(
                decoration: InputDecoration(
                    hintText: _textHint,
                ),
                autofocus: true,
                maxLines: null,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 30
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(Icons.calendar_today, color: ConstantHelper.tomatoColor,),
                    onPressed: () async{
                      await DateTimeSelector.show(context, null);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(Icons.timer, color: ConstantHelper.tomatoColor,),
                    onPressed: (){},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(Icons.info_outline, color: ConstantHelper.tomatoColor,),
                    onPressed: (){},
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(Icons.low_priority, color: ConstantHelper.tomatoColor,),
                    onPressed: (){},
                  ),
                ),
                Expanded(child: Container(),),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: FlatButton(
                     child: Text('Done', style: TextStyle(color: Colors.black26, fontSize: 18)),
                    onPressed: null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: Container(),)
        ],
      ),
    );
  }
}

class DateTimeSelector extends StatelessWidget{
  DateTime dateSelected;
  RepeatProperties repeatProperties;

  DateTimeSelector({DateTime selected}) : this.dateSelected = selected ?? dateOnly(DateTime.now());


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CalendarDatePicker(
              lastDate: DateTime(9999,12,31),
              initialDate: DateTime.now(),
              firstDate: dateOnly(DateTime.now()),
              onDateChanged: (DateTime date) => dateSelected = date,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          Container(
            child: ListTile(
              leading: Icon(Icons.repeat),
              title: Text('Repeat'),
              onTap: (){

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                  child: FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
              ),
              Container(
                  child: FlatButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: ConstantHelper.tomatoColor,
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context, dateSelected);
                    },
                  ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: Container(),)
        ],
      ),
      
    );
  }

  static show(context, DateTime date) async{
    DateTime dateSelected;
    dateSelected = await showDialog<DateTime>(context: context, builder: (_) => DateTimeSelector(selected: date,), barrierDismissible: true);
    return dateSelected;
  }
}