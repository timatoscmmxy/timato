import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:meta/meta.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:timato/ui/basics.dart';
import 'package:time_machine/time_machine.dart';

class StatsPage extends StatefulWidget{
  final List<int> weekDayTimerNums;
  final Map<String, int> tagTimerNumsToday;
  final Map<String, int> tagTimerNumsWeek;
  final int timerNumsToday;
  final int timerNumsWeek;

  StatsPage({
    @required this.weekDayTimerNums,
    @required this.tagTimerNumsToday,
    @required this.tagTimerNumsWeek,
    @required this.timerNumsToday,
    @required this.timerNumsWeek
  }): assert(weekDayTimerNums.length == 7),
      assert(tagTimerNumsWeek != null),
      assert(tagTimerNumsToday != null);

  @override
  State<StatefulWidget> createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage>{
  Map<String, int> byTagTimerNums;

  bool tagDataByDay = false;
  Widget byTagButton(){
    if (tagDataByDay){
      return FlatButton(
        child: Text(
          'Today',
          style: TextStyle(
            color: ConstantHelper.tomatoColor.withOpacity(0.5),
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        onPressed: (){
          setState(() {
            tagDataByDay = false;
            byTagTimerNums = widget.tagTimerNumsWeek;
          });
        },
      );
    } else{
      return FlatButton(
        child: Text(
          'Week',
          style: TextStyle(
              color: ConstantHelper.tomatoColor.withOpacity(0.5),
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        onPressed: (){
          setState(() {
            tagDataByDay = true;
            byTagTimerNums = widget.tagTimerNumsToday;
          });
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    byTagTimerNums = widget.tagTimerNumsWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () => Navigator.pop(context),
          color: ConstantHelper.tomatoColor,
        ),
        title: Text(
          'Number of Pomodoro Timers',
          style: TextStyle(
            color: ConstantHelper.tomatoColor
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          return Container(
            child: StaggeredGridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 10, right: 5, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                  color: ConstantHelper.tomatoColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    widget.timerNumsToday.toString(),
                                    style: TextStyle(
                                        color: ConstantHelper.tomatoColor
                                    ),
                                  ),
                                )
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 10, left: 5, top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'This Week',
                              style: TextStyle(
                                  color: ConstantHelper.tomatoColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Text(
                                    widget.timerNumsWeek.toString(),
                                    style: TextStyle(
                                        color: ConstantHelper.tomatoColor
                                    ),
                                  ),
                                )
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              'By Weekdays',
                              style: TextStyle(
                                  color: ConstantHelper.tomatoColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: SevenDayTimerBarChart(widget.weekDayTimerNums),
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 2.0,
                            spreadRadius: 0.0,
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'By Tags',
                                  style: TextStyle(
                                      color: ConstantHelper.tomatoColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Expanded(child:Container()),
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(10),
                                child: byTagButton()
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: DonutAutoLabelChart(byTagTimerNums),
                            ),
                          )
                        ],
                      ),
                    )
                ),
              ],
              staggeredTiles: [
                StaggeredTile.extent(2, constraints.maxHeight / 4),
                StaggeredTile.extent(2, constraints.maxHeight / 4),
                StaggeredTile.extent(4, constraints.maxHeight / 2 - 40),
                StaggeredTile.extent(4, constraints.maxHeight / 2 - 40),
              ],
            ),
          );
        },
      ),
    );
  }

}

class SevenDayTimerBarChart extends StatelessWidget {
  final List<int> timerNumList;

  SevenDayTimerBarChart(this.timerNumList);

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      getSeriesList(timerNumList),
      animate: true,
    );
  }

  List<charts.Series<_WeekdayTimerNumData, String>> getSeriesList(
      List<int> timerNums) {
    assert(timerNums.length == 7);
    List<_WeekdayTimerNumData> data = [];
    int initWeekday = DateTime
        .now()
        .add(Duration(days: -6))
        .weekday - 1;
    timerNums.forEach((element) {
      int weekday = initWeekday++ % 7;
      data.add(_WeekdayTimerNumData(
          DayOfWeek(weekday + 1).toString().substring(0, 2),
          element));
    });

    return [
      charts.Series<_WeekdayTimerNumData, String>(
        id: 'WeekdayTimerNum',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(ConstantHelper.tomatoColor),
        domainFn: (_WeekdayTimerNumData weekdayTimerNum, _) => weekdayTimerNum.weekday,
        measureFn: (_WeekdayTimerNumData weekdayTimerNum, _) => weekdayTimerNum.timerNum,
        data: data,
      )
    ];
  }
}

class _WeekdayTimerNumData {
  final String weekday;
  final int timerNum;

  _WeekdayTimerNumData(this.weekday, this.timerNum);
}

class DonutAutoLabelChart extends StatelessWidget {
  final Map<String, int> tagTimerNumPairs;

  DonutAutoLabelChart(this.tagTimerNumPairs);

  @override
  Widget build(BuildContext context) {
    if (tagTimerNumPairs.length == 0 || tagTimerNumPairs == null){
      return FittedBox(
        child: Text(
          'You haven\'t finished any pomodoro timers with tagged tasks',
          style: TextStyle(
              color: Colors.black38
          ),
        ),
      );
    }

    List<charts.Series<_TagTimerNumData, int>> seriesList = getSeriesList(tagTimerNumPairs);
    return charts.PieChart(seriesList,
        animate: true,
        defaultRenderer: charts.ArcRendererConfig(
            arcWidth: 30,
            arcRendererDecorators: [charts.ArcLabelDecorator(labelPosition: charts.ArcLabelPosition.outside)]));
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<_TagTimerNumData, int>> getSeriesList(Map<String, int> tagTimerNumPairs) {
    List<_TagTimerNumData> data = [];
    HSVColor colorUnit = HSVColor.fromColor(ConstantHelper.tomatoColor);

    List<MapEntry<String,int>> pairList = tagTimerNumPairs.entries.toList();
    pairList.sort((MapEntry<String,int> one, MapEntry<String,int> another) => another.value - one.value);
    int id = 0;
    for (MapEntry<String,int> pair in pairList){
      data.add(_TagTimerNumData(id++, pair.key, pair.value, colorUnit.withHue(50/tagTimerNumPairs.length*(id)).toColor()));
    }

    return [
      charts.Series<_TagTimerNumData, int>(
        id: 'tagTimerNum',
        domainFn: (_TagTimerNumData tagTimerNum, _) => tagTimerNum.id,
        measureFn: (_TagTimerNumData tagTimerNum, _) => tagTimerNum.timerNum,
        data: data,
        labelAccessorFn: (_TagTimerNumData row, _) => '${row.tag}: ${row.timerNum}',
        colorFn: (_TagTimerNumData row, __) =>
            charts.ColorUtil.fromDartColor(row.color),
      )
    ];
  }
}

/// Sample linear data type.
class _TagTimerNumData {
  final int id;
  final String tag;
  final int timerNum;
  final Color color;

  _TagTimerNumData(this.id, this.tag, this.timerNum, this.color);
}