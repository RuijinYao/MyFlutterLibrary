import 'package:my_flutter_library/database/SqlManager.dart';
import 'package:my_flutter_library/entity/TempRecord.dart';
import 'package:my_flutter_library/util/Constant.dart';
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  //表是否已创建
  bool isTableExits;

  String createTable = '''
            create table ${Constant.tableTempRecord} ( 
              ${Constant.columnId} integer primary key autoincrement, 
              ${Constant.columnTemp} double not null,
              ${Constant.columnStatus} integer default 0,
              ${Constant.columnTime} text not null,
              ${Constant.columnDate} text,
              ${Constant.columnMode} integer default 0,
              ${Constant.columnIsCelsius} integer default 1
            )''';

  Future open() async {
    Database db;
    isTableExits = await SqlManager.isTableExits(Constant.tableTempRecord);
    //表不存在则建表,存在就直接获取数据库对象
    if (!isTableExits) {
      db = await SqlManager.getCurrentDatabase();
      await db.execute(createTable);
    } else {
      db = await SqlManager.getCurrentDatabase();
    }
    return db;
  }

  Future close() async {
    Database db = await open();
    db.close();
  }

  Future<TempRecord> saveRecord(TempRecord record) async {
    Database db = await open();
    record.id = await db.insert(Constant.tableTempRecord, record.toMap());

    return record;
  }

  //Batch 批量操作, 效率更高
  Future saveRecords(List<TempRecord> records) async {
      Database db = await open();

      Batch batch = db.batch();
      records.forEach((record) {
          batch.insert(Constant.tableTempRecord, record.toMap());
      });
      batch.commit();

      return records.length;
  }


  //查询所有的测温记录, 降序排列
  Future<List<TempRecord>> getAllRecord() async {
    List<TempRecord> finallyList = [];
    Database db = await open();
    List<Map> originalList = await db.query(Constant.tableTempRecord, orderBy: "${Constant.columnId} desc");
    for (Map original in originalList) {
      finallyList.add(TempRecord.fromMap(original));
    }

    return finallyList;
  }

  //查询指定日期的测温记录, 降序排列
  Future<List<TempRecord>> getRecordsByDate(String date) async {
    List<TempRecord> finallyList = [];
    Database db = await open();
    List<Map> originalList = await db.query(Constant.tableTempRecord, where: '${Constant.columnDate} = ?', whereArgs: [date], orderBy: "${Constant.columnId} desc");
    for (Map original in originalList) {
      finallyList.add(TempRecord.fromMap(original));
    }

    return finallyList;
  }
}
