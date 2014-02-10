/* symbol.dart  */
import 'token.dart';

class Symbol{
  
  num scope;
  num line;
  String id;
  TokenType type;
  
  Symbol(this.scope, this.line, this.id, this.type);
}