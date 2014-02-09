
import '../../lib/enum.dart'; // Enum lib

class Token {
  TokenType type;
  var value;
  num position;
  String symbol;

  Token(this.type, this.value, this.position);
 
}

// Enum class that represents a token type
class TokenType extends Enum<String> {
  
  const TokenType(String val) : super(val);
  
  // "Symbols"
  static const EOF_SIGN = const TokenType("EOF_SIGN");
  static const OPEN_BRACE = const TokenType("OPEN_BRACE");
  static const CLOSE_BRACE = const TokenType("CLOSE_BRACE");
  static const OPEN_PAREN = const TokenType("OPEN_PAREN");
  static const CLOSE_PAREN = const TokenType("CLOSE_PAREN");
  static const EQUALS = const TokenType("EQUALS");
  static const OP = const TokenType("OP");
  static const QUOTE = const TokenType("QUOTE");
  static const DOUBLE_EQUALS = const TokenType("DOUBLE_EQUALS");
  
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
    return "TokenType=" + this.value;
  }
}