/* compiler.dart  */
import 'lexer.dart';
import 'parser.dart';
import 'token.dart';
import 'package:logging/logging.dart';

class Compiler{
  
  // Logging
  final Logger log = new Logger('Compiler');
  
  String source;
  List<Token> tokens = new List<Token>();
  Parser parser;
  
  Compiler(this.source);
  
  run(){
    this.tokens = Lexer.analyze(this.source);
    this.parser = new Parser(this.tokens);
    this.parser.analyse();
  }
}