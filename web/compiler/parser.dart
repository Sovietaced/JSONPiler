/* parser.dart  
 * 
 * Implements recursive descent parsing to analyze tokens
 * */
import 'token.dart';
import 'package:logging/logging.dart';

class Parser{
  
  // Logging
  static Logger log = new Logger('Parser');
  
  List<Token> tokens;
  num index = 0;
  
  Parser(this.tokens);
  
  analyse(){
    if(!tokens.isEmpty){
      
      while(index < tokens.length){
        Token token = tokens[index];
        print("parting");
        index++;
      }
    }
    else{
      log.warning("No tokens to parse, finished.");
    }
  }
  
  getNextToken(){
    return this.tokens[index+1];
  }
  
  expect(TokenType token){
    Token next = getNextToken();  
    if(next != token){
      log.severe("Unexpected symbol " + next.toString() + ", expected " + token.toString());
      return false;
    }
    return true;
  }
}