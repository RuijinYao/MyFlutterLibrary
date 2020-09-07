
import 'package:my_flutter_library/util/Constant.dart';

class TempRecord{
    int id;
    //温度
    double temp;
    //状态 0-健康, 1-偏高, 2-过热
    int status;
    //物温/体温模式 0-物温 1-体温
    int mode;
    //是否是摄氏度  0-不是, 1-是
    int isCelsius;
    //时间点
    String time;
    //日期
    String date;

    TempRecord({this.id, this.temp, this.status, this.mode, this.isCelsius, this.time, this.date});

    Map<String, dynamic> toMap() {
        var map = <String, dynamic>{
            Constant.columnTemp: temp,
            Constant.columnStatus: status,
            Constant.columnDate: date,
            Constant.columnTime: time,
            Constant.columnIsCelsius: isCelsius,
            Constant.columnMode: mode,
        };
        if (id != null) {
            map[Constant.columnId] = id;
        }
        return map;
    }

    TempRecord.fromMap(Map<String, dynamic> map) {
        id = map[Constant.columnId];
        temp = map[Constant.columnTemp];
        status = map[Constant.columnStatus];
        mode = map[Constant.columnMode];
        time = map[Constant.columnTime];
        date = map[Constant.columnDate];
        isCelsius = map[Constant.columnIsCelsius];
    }

    @override
    String toString() {
        return 'TempRecord{id: $id, temp: $temp, status: $status, mode: $mode, isCelsius: $isCelsius, time: $time, date: $date}';
    }
}