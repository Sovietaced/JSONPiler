/* parser.dart
 * Jason Parraga <Sovietaced@gmail.com>  
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
  
  /* This is the main method for the Parser where all the magic happens */
  analyse(){
    log.info("Parser analyzing...");
    if(!tokens.isEmpty){
       if(tokens.first.type == TokenType.OPEN_BRACE){
         index++;
         statement();
       }
       else{
         log.error("Program does not start with a block");
         // quit
       }
    }
    else{
      log.warning("No tokens to parse, finished.");
    }
  }
  
  Token getNextToken(){
    if(index < this.tokens.length - 1){
      return this.tokens[index+1];
    }
    else{
      return null;
    }
  }
  
  bool expect(TokenType token){
    Token next = getNextToken();  
    if(next != token){
      log.severe("Unexpected symbol " + next.toString() + ", expected " + token.toString());
      return false;
    }
    return true;
  }
  
  /* Determines if the next token is the type of token
   * that we're looking for. Used for determing the next statement. 
   */
  bool isNextToken(TokenType token){
    Token next = getNextToken();  
    if(next != token){
      return false;
    }
    return true;
  }
  
  void block(){
    Token next = getNextToken();
  }
  
  void varDeclaration(){
    
  }
  
  void statement(){
    Token token = getNextToken();
    
    if(token.type == TokenType.PRINT){
      print("We have a print token");
    }
    
  }
}