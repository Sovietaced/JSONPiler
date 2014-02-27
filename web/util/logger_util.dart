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
    if (!querySelector("#log").text.contains(line)){
      querySelector("#log").appendText(line);
    }
  }
}