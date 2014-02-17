/* parser.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Implements recursive descent parsing to analyze tokens
 * */

import 'token.dart';
import 'symbol.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';

class Parser{
  
  // Logging
  static Logger log = new Logger('Parser');
  
  List<Token> tokens;
  // Simple for now
  List<Symbol> symbols = new List<Symbol>();
  num index = 0;
  num scope = 0;
  
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
  
  void block(){
    // Entering a block denotes new scope
    scope++;
    
    Token token = getToken();
    
    if(token.type == TokenType.OPEN_BRACE){
      statement();
    }
    else{
      log.severe("Program must begin with a block");
    }
    // Exiting a block denotes new scope
    scope--;
  }
  void statement(){
    Token token = popNextToken();
    
    while(token.type != TokenType.CLOSE_BRACE){
      if(token.type == TokenType.PRINT){
        printStatement();
      }
      else if(token.type == TokenType.TYPE){
        variableDeclaration(token);
      }
      else if(token.type == TokenType.ID){
        assignmentStatement(token);
      }
      else if(token.type == TokenType.IF){
        ifStatement();
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
  
  /* Handles the assignment statement.
   * The token passed is the left hand side of the assignment.
   * this is done for type checking.
   */
  void assignmentStatement(Token token){
    log.info("Parsing assignment statement");
    // First make sure the left hand side is a valid reference
    checkSymbol(token.value);
    // Equals assignment
    expect(TokenType.EQUALS);
    // Check right hand side
    expression(token.value);
  }
  
  void ifStatement(){
    log.info("Parsing if statement");
    expect(TokenType.OPEN_PAREN);
    expression();
    expect(TokenType.CLOSE_PAREN);
  }
  
  /* VARIABLE DECLARATIONS */
  void variableDeclaration(Token typeToken){
    log.info("Parsing variable declaration");
    expect(TokenType.ID);
    
    // Get the ID token
    Token token = getToken();

    // Generate the symbol with both the ID and type from both tokens
    Symbol symbol = new Symbol(token.value, this.scope, token.line, typeToken.value);
    // Add this new symbol to our list of symbols
    this.symbols.add(symbol);
  }
  
  /* TYPE EXPRESSIONS */
  
  void expression([ID = null]){
    
    log.info(ID);
    if(isNextToken(TokenType.DIGIT)){
      intExpression(ID);
    }
    else if(isNextToken(TokenType.BOOLEAN)){
      booleanExpression(ID);
    }
    // Otherwise it must be a string
    else if(isNextToken(TokenType.QUOTE)){
      stringExpression(ID);
    }
  }
  
   void intExpression([ID = null]){   
    expect(TokenType.DIGIT, ID);
   }
    
    void booleanExpression([ID = null]){
      expect(TokenType.BOOLEAN, ID);
    }
  
  
  void stringExpression([ID = null]){
    
    // Opening Quote
    expect(TokenType.QUOTE, ID);
    
    // Validate at least one character exists
    expect(TokenType.CHAR, ID);
  
    // Iterate over the rest of the string
    while(peekNextToken() != null && peekNextToken().type == TokenType.CHAR){
      expect(TokenType.CHAR, ID);
    }
    
    // Closing Quote
    expect(TokenType.QUOTE, ID);
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
  
  void expect(TokenType type, [ID = null]){
    Token next = popNextToken();  
    
    if(next.type != type){
      throw new SyntaxError("Expected type " + type.value + ", found type " + next.type.value);
    }
    if(ID != null){
      checkSymbolType(next, ID);
    }
  }
  
  void checkSymbolType(Token token, String ID){
    // Get the symbol
    Symbol symbol = findSymbol(ID);
    if( (symbol.type == "int" && token.type != TokenType.DIGIT) ||
        (symbol.type == "string" && token.type != TokenType.CHAR && token.type != TokenType.QUOTE) ||
        (symbol.type == "boolean" && token.type != TokenType.BOOLEAN)
        ){
      log.severe("Type mismatch. Attempted to assign value of type " + token.type.value + " to " + symbol.type + " $ID");
    }
  }
  
  void checkSymbol(String symbolID){
    for(Symbol symbol in this.symbols){
      if(symbol.id == symbolID){
        return;
      }
    }
    log.severe("Identifier " + symbolID + "not found.");
  }
  
  Symbol findSymbol(String symbolID){
    for(Symbol symbol in this.symbols){
      if(symbol.id == symbolID){
        return symbol;
      }
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
  
}