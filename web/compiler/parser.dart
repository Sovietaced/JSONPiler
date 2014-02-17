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
    log.info("Parser starting analysis...");
    if(!tokens.isEmpty){
       block();
       log.info("Parser finished analysis...");
    }
    else{
      log.warning("No tokens to parse, finished.");
    }
  }
  
  /* This gets the next token and increments the index.
   * Named pop to imply mutating behavior.
   */
  Token popNextToken(){
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
    Token next = popNextToken();  
    
    if(next.type != type){
      log.severe("Unexpected symbol " + next.value + ", expected " + type.value);
    }
  }
  
  /* Determines if the next token is the type of token
   * that we're looking for. Used for determing the next statement. 
   */
  bool isNextToken(TokenType type){
    Token next = peekNextToken();  
    if(next.type != type){
      return false;
    }
    return true;
  }
  
  void block(){
    Token token = getToken();
    
    if(token.type == TokenType.OPEN_BRACE){
      statement();
    }
    else{
      log.severe("Program must begin with a block");
    }
  }
  void statement(){
    Token token = popNextToken();
    
    while(token.type != TokenType.CLOSE_BRACE){
      if(token.type == TokenType.PRINT){
        printStatement();
      }
      else if(token.type == TokenType.TYPE){
        variableDeclaration();
      }
      else if(token.type == TokenType.ID){
        log.info(token.toString());
        assignmentStatement();
      }
      
      // Change sentinel value
      token = popNextToken();
    }
  }
  
  /* STATEMENTS */
  void printStatement(){
    log.info("Parsing print statement");
    expect(TokenType.OPEN_PAREN);
    stringExpression();  
    expect(TokenType.CLOSE_PAREN);
  }
  
  void assignmentStatement(){
    log.info("Parsing assignment statement");
    expect(TokenType.EQUALS);
    expression();
  }
  
  /* VARIABLE DECLARATIONS */
  void variableDeclaration(){
    log.info("Parsing variable declaration");
    expect(TokenType.ID);
  }
  
  /* TYPE EXPRESSIONS */
  
  void expression(){
    
    if(isNextToken(TokenType.DIGIT)){
      intExpression();
    }
    else if(isNextToken(TokenType.BOOLEAN)){
      booleanExpression();
    }
    // Otherwise it must be a string
    else{
      stringExpression();
    }
  }
  
   void intExpression(){   
    expect(TokenType.DIGIT);
   }
    
    void booleanExpression(){
      
      // We have to experct a boolean value or a boolean expression here...
      if(peekNextToken() != null && peekNextToken().type == TokenType.BOOLEAN){
        expect(TokenType.BOOLEAN);
      }
      else{
        log.severe("TODO : Handle boolean expression");
      }
    }
  
  
  void stringExpression(){
    
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