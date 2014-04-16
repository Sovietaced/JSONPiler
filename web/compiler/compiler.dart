/* compiler.dart  */
import 'lexer.dart';
import 'parser.dart';
import 'semanticAnalyzer.dart';
import 'token.dart';
import '../lib/tree.dart';
import 'package:logging/logging.dart';
import '../util/logger_util.dart';

class Compiler{
  
  // Logging
  final Logger log = LoggerUtil.createLogger('Compiler');
  
  String source;
  List<Token> tokens = new List<Token>();
  Tree<dynamic> cst;
  Tree<dynamic> ast;
  Parser parser;
  
  Compiler(this.source);
  
  run(){
    try{
      this.tokens = Lexer.analyze(this.source);
      this.parser = new Parser(this.tokens);
      this.cst = this.parser.analyse();
      this.ast = SemanticAnalyzer.analyze(this.cst);
    }catch(e){
      // Let log and throw handle
    }
  }
}