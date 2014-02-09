
import 'lib/enum.dart'; // Enum lib

class Token {
  Type type;
  var value;
  num position;
  String symbol;

  Token(this.type, this.value, this.position);
 
}

// Enum class that represents a token type
class Type extends Enum<String> {
  
  const Type(String val) : super(val);
  // "Symbols"
  static const EOF_SIGN = const Type("EOF_SIGN");
  static const OPEN_BRACE = const Type("OPEN_BRACE");
  static const CLOSE_BRACE = const Type("CLOSE_BRACE");
  static const OPEN_PAREN = const Type("OPEN_PAREN");
  static const CLOSE_PAREN = const Type("CLOSE_PAREN");
  static const EQUALS = const Type("EQUALS");
  static const OP = const Type("OP");
  static const QUOTE = const Type("QUOTE");
  static const DOUBLE_EQUALS = const Type("DOUBLE_EQUALS");
  
  // Reserved words
  static const TYPE = const Type("TYPE");
  static const PRINT = const Type("PRINT");
  static const WHILE = const Type("WHILE");
  static const IF = const Type("IF");
  
  // Values
  static const DIGIT = const Type("DIGIT");
  static const CHAR = const Type("CHAR");
  static const BOOLEAN = const Type("BOOLEAN");
  static const SPACE = const Type("SPACE");
  static const ID = const Type("ID");
  
  static const EPSILON = const Type("EPSILON"); // User cannot enter this, the parser does it.
}