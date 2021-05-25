class Task {
  static const tblTask = 'task';
  static const colId = 'id';
  static const colName = 'name';
  static const colDesc = 'desc';

  Task({this.id, this.name, this.desc});

  int? id;
  String? name;
  String? desc;

  Task.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    name = map[colName];
    desc = map[colDesc];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colName: name, colDesc: desc};
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }
}
