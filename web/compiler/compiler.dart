/* compiler.dart  */
import 'lexer.dart';
import 'parser.dart';
import 'codeGenerator.dart';
import 'symbol.dart';
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
  List<CompilerSymbol> symbols;
  Tree<dynamic> cst;
  Tree<dynamic> ast;
  Parser parser;
  SemanticAnalyzer analyzer;
  CodeGenerator codeGenerator;
  
  Compiler(this.source);
  
  run(){
    //try{
      this.tokens = Lexer.analyze(this.source);
      this.parser = new Parser(this.tokens);
      var hash = this.parser.analyse();
      this.cst = hash['cst'];
      this.symbols = hash['symbols'];
      analyzer = new SemanticAnalyzer(this.cst, this.symbols);
      this.ast = analyzer.analyze();
      this.codeGenerator = new CodeGenerator(this.ast);
      String output = this.codeGenerator.generateCode();
      
    //}catch(e){
      // Let log and throw handle
    //}
  }
}