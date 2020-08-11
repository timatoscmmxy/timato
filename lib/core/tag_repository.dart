import 'package:sqflite/sqflite.dart';
import 'package:timato/core/db.dart';
import 'package:timato/ui/add_event.dart';

class TagEntity {
  static final String tagTable = 'tag_table';
  static final String colDate = 'date';
  static final String colTag = 'tag';
  static final String colNum = 'num';

  static void createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tagTable($colDate TEXT, $colTag TEXT, $colNum INTEGER)');
  }

  static upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 3) {
      await db.execute(
          'CREATE TABLE $tagTable($colDate TEXT, $colTag TEXT, $colNum INTEGER)');
    }
  }
}

void updateTag(String tag, int usedTimerNum) async {
  Database db = await DatabaseHelper.database;
  var tags;
  tags = await db.query(TagEntity.tagTable,
      where:
          "${TagEntity.colDate} = ${dateOnly(DateTime.now()).toString()} and ${TagEntity.colTag} = ${tag ?? 'is null'}");

  if (tags.length == 0) {
    await db.insert(TagEntity.tagTable, {
      TagEntity.colDate: dateOnly(DateTime.now()).toString(),
      TagEntity.colTag: tag,
      TagEntity.colNum: usedTimerNum
    });
  } else {
    var tagRow = tags[0];
    await db.update(TagEntity.tagTable, {TagEntity.colNum: tagRow[TagEntity.colNum] + usedTimerNum},
        where:
            "${TagEntity.colDate} = \"${tagRow[TagEntity.colDate]}\" and ${TagEntity.colTag} = \"${tag ?? 'is null'}\"");
  }
}

Future<List<int>> getWeekTimerNum() async {
  Database db = await DatabaseHelper.database;
  DateTime today = dateOnly(DateTime.now());
  List<int> result = [];
  for (int i = 0; i < 7; ++i) {
    List<Map<String, dynamic>> tags = await db.query(TagEntity.tagTable,
        columns: [TagEntity.colNum],
        where: "${TagEntity.colDate} = \"${today.toString()}\"");
    int sum = tags.fold(0, (previousValue, element) => previousValue??0 + element[TagEntity.colNum]);
    result.insert(0, sum);
  }
  return result;
}

Future<Map<String, int>> getTodayTagTimerNum() async{
  Database db = await DatabaseHelper.database;
  DateTime today = dateOnly(DateTime.now());
  Map<String,int> result = {};
  List<Map<String, dynamic>> tags = await db.query(TagEntity.tagTable,
      columns: [TagEntity.colNum, TagEntity.colTag],
      where: "${TagEntity.colDate} = \"${today.toString()}\"");
  for (var tagRow in tags){
    result.addAll({tagRow[TagEntity.colTag] : tagRow[TagEntity.colNum]});
  }
  return result;
}

Future<Map<String, int>> getWeekTagTimerNum() async{
  Database db = await DatabaseHelper.database;
  List<Map<String, dynamic>> tags = [];
  DateTime today = dateOnly(DateTime.now());
  Map<String,int> result = {};
  for (int i = 0; i < 7; ++i) {
    tags.addAll(await db.query(TagEntity.tagTable,
        columns: [TagEntity.colNum],
        where: "${TagEntity.colDate} = \"${today.toString()}\""));
  }
  for (var tagRow in tags){
    String key = tagRow[TagEntity.colTag];
    if (result.containsKey(key)){
      result.update(key, (value) => value + tagRow[TagEntity.colNum]);
    }
  }
  return result;
}

Future<int> getTodayTimerNum() async{
  Database db = await DatabaseHelper.database;
  DateTime today = dateOnly(DateTime.now());
  List<Map<String, dynamic>> tags = await db.query(TagEntity.tagTable,
      columns: [TagEntity.colNum],
      where: "${TagEntity.colDate} = \"${today.toString()}\"");
  return  tags.fold(0, (previousValue, element) => previousValue??0 + element[TagEntity.colNum]);

}

printDatabase() async{
  Database db = await DatabaseHelper.database;
  print(await db.query(TagEntity.tagTable));
}