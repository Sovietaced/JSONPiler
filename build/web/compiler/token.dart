/* token.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Compiler token class. Also an enum class for the different static token types.
 * */
library Token;

import '../lib/enum.dart'; // Enum lib

class Token {
  TokenType type;
  var value;
  num line;
  String symbol;

  Token(this.type, this.value, this.line);
 
  String toString(){
    return "Token type=${this.type.value} value=${this.value} line=${this.line.toString()}";
  }
}

// Enum class that represents a token type
class TokenType extends Enum<String> {
  
  static final SYMBOLS = { "{" : TokenType.OPEN_BRACE,
                  "}" : TokenType.CLOSE_BRACE,
                  "(" : TokenType.OPEN_PAREN,
                  ")" : TokenType.CLOSE_PAREN,
                  "==" : TokenType.BOOL_OP,
                  "!=" : TokenType.BOOL_OP,
                  "+" : TokenType.INT_OP,
                  "=" : TokenType.EQUALS};
  
  static final RESERVED = { "int" : TokenType.TYPE,
                           "string" : TokenType.TYPE,
                           "boolean" : TokenType.TYPE,
                           "print" : TokenType.PRINT,
                           "while" : TokenType.WHILE,
                           "if" : TokenType.IF,
                           "false" : TokenType.BOOLEAN,
                           "true" : TokenType.BOOLEAN};
  
  const TokenType(String value) : super(value);
  
  // Symbols
  static const END = const TokenType("END");
  static const OPEN_BRACE = const TokenType("OPEN_BRACE");
  static const CLOSE_BRACE = const TokenType("CLOSE_BRACE");
  static const OPEN_PAREN = const TokenType("OPEN_PAREN");
  static const CLOSE_PAREN = const TokenType("CLOSE_PAREN");
  static const EQUALS = const TokenType("EQUALS");
  static const QUOTE = const TokenType("QUOTE");
  static const BOOL_OP = const TokenType("BOOL_OP");
  static const INT_OP = const TokenType("INT_OP");
  
  // Reserved words
  static const TYPE = const TokenType("TYPE");
  static const PRINT = const TokenType("PRINT");
  static const WHILE = const TokenType("WHILE");
  static const IF = const TokenType("IF");
  
  // Values
  static const DIGIT = const TokenType("DIGIT");
  static const CHAR = const TokenType("CHAR");
  static const BOOLEAN = const TokenType("BOOLEAN");
  static const SPACE = const TokenType("SPACE");
  static const ID = const TokenType("ID");
  
  static const EPSILON = const TokenType("EPSILON"); // User cannot enter this, the parser does it.
  
  String toString(){
      return "Token type=${this.value}";
    }
}