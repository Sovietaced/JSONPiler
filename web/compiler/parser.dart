/* parser.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Implements recursive descent parsing to analyze tokens
 * */

import 'token.dart';
import 'symbol.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';
import '../util/logger_util.dart';
import '../util/exception_util.dart';

class Parser{
  
  // Logging
  static Logger log = LoggerUtil.createLogger('Parser');
  
  List<Token> tokens;
  // Simple for now
  List<CompilerSymbol> symbols = new List<CompilerSymbol>();
  num index = 0;
  num scope = 0;
  
  Parser(this.tokens);
  
  /* This is the main method for the Parser where all the magic happens */
  analyse(){
    log.info("Parser starting analysis...");
    if(!tokens.isEmpty){
      
      block();
      
      Token token = popNextToken();
      
      if(token.type != TokenType.END){
        ExceptionUtil.logAndThrow(new CompilerSyntaxError("Expected END token, found type " + token.type.value + " on line " + token.line.toString()), log);
      }
      log.info("Parser finished analysis...");
    }
    else{
      log.warning("No tokens to parse, finished.");
    }
  }

  void block(){
    // Entering a block denotes new scope
    scope++;
    
    statementList();

    // Exiting a block denotes new scope
    scope--;
    
  }
  
  void statementList(){
    // seed
    Token token = popNextToken();
    
    while(token.type != TokenType.CLOSE_BRACE){
      if(token.type == TokenType.TYPE){
        variableDeclaration(token);
      }
      else if(token.type == TokenType.ID){
        assignmentStatement(token);
      }
      else if(token.type == TokenType.IF){
        ifStatement();
      }
      else if(token.type == TokenType.WHILE){
        whileStatement();
      }
      else if(token.type == TokenType.PRINT){
        printStatement();
      }
      else if(token.type == TokenType.OPEN_BRACE){
        block();
      }
      else{
        ExceptionUtil.logAndThrow(new CompilerSyntaxError("Expected statement, found type " + token.type.value + " on line " + token.line.toString()), log);
      }
  
      // Change sentinel value
      token = popNextToken();
    }
  }
  
  /* STATEMENTS */
  void printStatement(){
    log.info("Parsing print statement on line " + getLine());
    expect(TokenType.OPEN_PAREN);
    expression();  
    expect(TokenType.CLOSE_PAREN);
  }
  
  /* ASSIGNMENT STATEMENTS */
  void assignmentStatement(Token token){
    log.info("Parsing assignment statement on line " + getLine());
    
    // Equals assignment
    expect(TokenType.EQUALS);
    
    if(isNextToken(TokenType.DIGIT)){
      intExpression();   
    }
    // Assignment can be for boolval or boolean expression
    else if(isNextToken(TokenType.BOOLEAN)){
      expect(TokenType.BOOLEAN);
    }
    else if(isNextToken(TokenType.OPEN_PAREN)){
      condition();
    }
    // Otherwise it must be a string
    else if(isNextToken(TokenType.QUOTE)){
      stringExpression();
    }
    else if(isNextToken(TokenType.ID)){
      expect(TokenType.ID);
    }
  }
  
  /* IF STATEMENT */
  void ifStatement(){
    log.info("Parsing if statement on line " + getLine());
    condition();
    block();
  }
  
  /* WHILE STATEMENT */
  void whileStatement(){
    log.info("Parsing while statement on line " + getLine());
    condition();
    block();
  }
  
  /* VARIABLE DECLARATIONS */
  
  // Checks for an ID type token, creates the symbol, and adds it to the symbol table
  void variableDeclaration(Token typeToken){
    log.info("Parsing variable declaration on line " + getLine());
    expect(TokenType.ID);
    
    // Get the ID token
    Token token = getToken();

    // Generate the symbol with both the ID and type from both tokens
    CompilerSymbol symbol = new CompilerSymbol(token.value, this.scope, token.line, typeToken.value);
    // Add this new symbol to our list of symbols
    this.symbols.add(symbol);
  }
  
  /* TYPE EXPRESSIONS */
  
  void expression(){
    
    log.info("Parsing an expression on line " + getLine());
    if(isNextToken(TokenType.DIGIT)){
      intExpression();
    }
    else if(isNextToken(TokenType.BOOLEAN)){
      expect(TokenType.BOOLEAN);
    }
    else if(isNextToken(TokenType.OPEN_PAREN)){
     condition();
    }
    // Otherwise it must be a string
    else if(isNextToken(TokenType.QUOTE)){
      stringExpression();
    }
    else if(isNextToken(TokenType.ID)){
      expect(TokenType.ID);
    }
    else{
      print("idk");
    }
  }
  
  void intExpression(){
    // Check for type int
    expect(TokenType.DIGIT);
    
    // Handle int operations aka +
    if(isNextToken(TokenType.INT_OP)){
      expect(TokenType.INT_OP);
      expression();
    }
  }
  
  void stringExpression(){
    
    // Opening Quote
    expect(TokenType.QUOTE);
  
    // Iterate over the rest of the string
    while(peekNextToken() != null && (isNextToken(TokenType.CHAR) || isNextToken(TokenType.SPACE))){
      expectOneOf([TokenType.CHAR, TokenType.SPACE]);
    }
    
    // Closing Quote
    expect(TokenType.QUOTE);
  }
  
  // Parses Conditionals and does type checking
  void condition(){
    
    // Handles conditionals within parenthesis
    if(peekNextToken().type == TokenType.OPEN_PAREN){
      expect(TokenType.OPEN_PAREN);
      
      // Left Hand
      expression();
  
      // Boolean expression
      expect(TokenType.BOOL_OP);
      
      // Right Hand
      expression();
      expect(TokenType.CLOSE_PAREN);
    }
    // Handles simple conditionals without parenthesis (true/false)
    else{
      expect(TokenType.BOOLEAN);
    }
  }
  
  /* TOKEN HELPERS */
   
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
  
  // Looks at the next token without incrementing the current token pointer
  Token peekNextToken(){
    if(index < this.tokens.length - 1){
      return this.tokens[index + 1];
    }
    else{
      return null;
    }
  }
  
  // Gets the current token
  Token getToken(){
    if(index < this.tokens.length){
      return this.tokens[index];
    }
    else{
      return null;
    }
  }
  
  // Gets the current token line
  String getLine(){
    return getToken().line.toString();
  }
  
  // Checks to see if the next token is what it should be
  void expect(TokenType type){
    Token next = popNextToken();  
    
    if(next.type != type){
      ExceptionUtil.logAndThrow(new CompilerSyntaxError("Expected token of type " + type.value + ", found type " + next.type.value + " on line " + next.line.toString()), log);
    }
  }
  
// Checks to see if the next token is what it should be
  void expectOneOf(List<TokenType> types){
    Token next = popNextToken();  
    
    for(TokenType type in types){
      if(next.type == type){
        return;
      }
    }
    // In case not found
    ExceptionUtil.logAndThrow(new CompilerTypeError("Expected token of type " + types.toString() + ", found type " + next.type.value + " on line " + next.line.toString()), log);
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
  
  
}