/* symbol.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Compiler symbol class
 * */

library Symbol;

import 'dart:html';
import '../lib/enum.dart'; // Enum lib

class CompilerSymbol{
  
  String id;
  num scope;
  num line;
  String type;
  
  CompilerSymbol(this.id, this.scope, this.line, this.type){
    querySelector("#symbol-table").appendText(this.toString());
  }
  
  String toString(){
    return "Symbol: name=${this.id} scope=${this.scope} line=${this.line} type=${this.type} \n";
  }
}

// Enum class that represents a token type
class NonTerminal extends Enum<String> {
  
  const NonTerminal(String value) : super(value);
  
  // Symbols
  static const PROGRAM = const NonTerminal("PROGRAM");
  static const BLOCK = const NonTerminal("BLOCK");
  
  static const STATEMENT_LIST = const NonTerminal("STATEMENT_LIST");
  static const STATEMENT = const NonTerminal("STATEMENT");
  static const IF_STATEMENT = const NonTerminal("IF_STATEMENT");
  static const WHILE_STATEMENT = const NonTerminal("WHILE_STATEMENT");
  static const PRINT_STATEMENT = const NonTerminal("PRINT_STATEMENT");
  static const ASSIGNMENT_STATEMENT = const NonTerminal("ASSIGNMENT_STATEMENT");
  
  static const VARIABLE_DECLARATION = const NonTerminal("VARIABLE_DECLARATION");
  
  static const EXPRESSION = const NonTerminal("EXPRESSION");
  static const INT_EXPRESSION = const NonTerminal("INT_EXPRESSION");
  static const BOOLEAN_EXPRESSION = const NonTerminal("BOOLEAN_EXPRESSION");
  static const STRING_EXPRESSION = const NonTerminal("STRING_EXPRESSION");
  static const ID_EXPRESSION = const NonTerminal("ID_EXPRESSION");
  
  static const CHAR_LIST = const NonTerminal("CHAR_LIST");
  
  
  String toString(){
        return "NonTerminal=${this.value}";
      }
}