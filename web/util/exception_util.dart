library ExceptionUtil;

import 'package:logging/logging.dart';

class ExceptionUtil{
 
  static void logAndThrow(Exception e, Logger log){
    log.severe(e.toString());
    throw e;
  }
}