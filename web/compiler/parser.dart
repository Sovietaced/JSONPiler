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
      return this.tokens[++index];
    }
    else{
      return null;
    }
  }
  
  Token peekNextToken(){
    if(index < this.tokens.length - 1){
      return this.tokens[index + 1];
    }
    else{
      return null;
    }
  }
  
  Token getToken(){
    if(index < this.tokens.length){
      return this.tokens[index];
    }
    else{
      return null;
    }
  }
  
  void expect(TokenType type){
    Token next = getNextToken();  
    
    if(next.type != type){
      log.severe("Unexpected symbol " + next.value + ", expected " + type.value);
    }
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
      printStatement();
    }    
  }
  
  /* STATEMENTS */
  void printStatement(){
    log.info("Parsing print statement");
    expect(TokenType.OPEN_PAREN);
    stringExpr();  
    expect(TokenType.CLOSE_PAREN);
  }
  
  void stringExpr(){
    
    // Opening Quote
    expect(TokenType.QUOTE);
    
    // Validate at least one character exists
    expect(TokenType.CHAR);
  
    // Iterate over the rest of the string
    while(peekNextToken() != null && peekNextToken().type == TokenType.CHAR){
      expect(TokenType.CHAR);
    }
    
    // Closing Quote
    expect(TokenType.QUOTE);
  }
}