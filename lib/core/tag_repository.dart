import 'db.dart';

class TagRepository extends DatabaseHelper {
  static TagRepository _databaseHelper; // Singleton DatabaseHelper
  TagRepository._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory TagRepository() {
    if (_databaseHelper == null) {
      _databaseHelper = TagRepository
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }
}