import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timato/ui/basics.dart';

class AddEvent extends StatelessWidget{
  final String _textHint;
  final bool isPlanned;

  AddEvent(this._textHint, {this.isPlanned});

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
                    hintText: _textHint
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
                    onPressed: (){},
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