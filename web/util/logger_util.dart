library LoggerUtil;

import 'dart:html';
import 'package:logging/logging.dart';

class LoggerUtil{
  
  static Logger createLogger(String name){
    Logger log = new Logger(name);
    log.onRecord.listen(LoggerUtil.printLogRecord);
    return log;
  }
  
  static void printLogRecord(LogRecord r) {
    String line = "${r.level}: ${r.time}: ${r.message}\n";
    // Sloppy bug fix because this gets called twice :/
    if (!querySelector("#log-all").text.contains(line)){
      querySelector("#log-all").appendText(line);
      String badgeAll = querySelector("#badge-all").text;
      querySelector("#badge-all").text = (num.parse(badgeAll) + 1).toString();
      
      String level = r.level.toString().toLowerCase();
      querySelector("#log-$level").appendText(line);     
      
      String badge = querySelector("#badge-$level").text;
      querySelector("#badge-$level").text = (num.parse(badge) + 1).toString();
    }
  }
}