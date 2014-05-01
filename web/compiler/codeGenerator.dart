/* codeGenerator.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

library codeGenerator;

import '../util/logger_util.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart'; 
import 'token.dart';
import 'exceptions.dart';
import '../util/exception_util.dart';


class CodeGenerator{
  
  // Logging
  static Logger log = LoggerUtil.createLogger('CodeGenerator');
  
  Tree<dynamic> ast;
  
  CodeGenerator(this.ast);
  
  void generateCode() {
    
  }
  
}