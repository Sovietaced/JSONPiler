/* semanticAnalyzer.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

import 'token.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart'; 
import '../util/logger_util.dart';
import '../util/exception_util.dart';

class SemanticAnalyzer {

  // Logging
  static Logger log = LoggerUtil.createLogger('SemanticAnalyzer');

  /**
   *  This is the main method for the Semantic Analyzer where all the magic happens 
   */
  static analyze(Tree<dynamic> cst) {
    log.info("Semantic Analyzer starting analysis...");
    if (!cst.children.isEmpty) {

      // Instantiate AST
      Tree<dynamic> ast = new Tree<dynamic>("Program", null);
  
      ast.dump();
      log.info("Semantic Analyzer finished analysis...");
      return cst;
    } else {
      log.warning("CST is empty, finished.");
    }
  }
}
