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
  num index = -1;
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
    
    Token token = popNextToken();
    
    if(token.type == TokenType.OPEN_BRACE){
      parseStatements();
    }
    else{
      throw new SyntaxError("Program must begin with a block");
    }
    // Exiting a block denotes new scope
    scope--;
  }
  void parseStatements(){
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
      else if(token.type == TokenType.WHILE){
        whileStatement();
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
  
  /* ASSIGNMENT STATEMENTS */
  void assignmentStatement(Token token){
    log.info("Parsing assignment statement");
    
    String ID = token.value;
    
    // First make sure the left hand side is a valid reference to a symbol
    checkSymbol(ID);
    
    // Equals assignment
    expect(TokenType.EQUALS);
    
    if(isNextToken(TokenType.DIGIT)){
      intExpression(ID);   
    }
    // Assignment can be for boolval or boolean expression
    else if(isNextToken(TokenType.BOOLEAN)){
      expect(TokenType.BOOLEAN, ID);
    }
    else if(isNextToken(TokenType.OPEN_PAREN)){
      condition(ID);
    }
    // Otherwise it must be a string
    else if(isNextToken(TokenType.QUOTE)){
      stringExpression(ID);
    }
    else if(isNextToken(TokenType.ID)){
      expect(TokenType.ID, ID);
    }
  }
  
  /* IF STATEMENT */
  void ifStatement(){
    log.info("Parsing if statement");
    condition();
    block();
  }
  
  /* WHILE STATEMENT */
  void whileStatement(){
    log.info("Parsing while statement");
    condition();
    block();
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
    if(isNextToken(TokenType.DIGIT)){
      intExpression(ID);
    }
    else if(isNextToken(TokenType.BOOLEAN)){
      expect(TokenType.BOOLEAN, ID);
    }
    else if(isNextToken(TokenType.OPEN_PAREN)){
     condition();
    }
    // Otherwise it must be a string
    else if(isNextToken(TokenType.QUOTE)){
      stringExpression(ID);
    }
    else if(isNextToken(TokenType.ID)){
      expect(TokenType.ID, ID);
    }
    else{
      print("idk");
    }
  }
  
  void intExpression([ID = null]){
    // Check for type int
    expect(TokenType.DIGIT, ID);
    
    // Handle int operations aka +
    if(isNextToken(TokenType.INT_OP)){
      Token leftHand = getToken();
      expect(TokenType.INT_OP);
      expect(TokenType.DIGIT);
      Token rightHand = getToken();
      
      // Make sure both sides of the operand are of type int
      checkTypes(leftHand, rightHand);
    }
  }
  
  void stringExpression([ID = null]){
    
    // Opening Quote
    expect(TokenType.QUOTE, ID);
    
    // Validate at least one character exists
    expect(TokenType.CHAR, ID);
  
    // Iterate over the rest of the string
    while(peekNextToken() != null && (peekNextToken().type == TokenType.CHAR || peekNextToken().type == TokenType.SPACE)){
      expectOneOf([TokenType.CHAR, TokenType.SPACE]);
    }
    
    // Closing Quote
    expect(TokenType.QUOTE, ID);
  }
  
  // Parses Conditionals and does type checking
  void condition([ID = null]){
    // In case this condition is being assigned
    if(ID != null){
      checkSymbolTypeAgainstTokenType(TokenType.BOOLEAN, ID);
    }
    
    expect(TokenType.OPEN_PAREN);
    
    // Left Hand
    expression();
    Token leftHand = getToken();

    // Boolean expression
    expect(TokenType.BOOL_OP);
    
    // Right Hand
    expression();
    Token rightHand = getToken();
    
    expect(TokenType.CLOSE_PAREN);
    
    // Check type of two tokens
    checkTypes(leftHand, rightHand);
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
  
  // Checks to see if the next token is what it should be
  void expect(TokenType type, [ID = null]){
    Token next = popNextToken();  
    
    if(next.type != type){
      throw new TypeError("Expected type " + type.value + ", found type " + next.type.value + " on line " + next.line.toString());
    }
    if(ID != null){
      checkSymbolTypeAgainstToken(next, ID);
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
    throw new TypeError("Expected one of type " + types.toString() + ", found type " + next.type.value + " on line " + next.line.toString());
  }
  
  void checkSymbolTypeAgainstTokenType(TokenType type, String ID){
    // Get the symbol
    Symbol symbol = findSymbol(ID);
    
    if((symbol.type == "int" && type != TokenType.DIGIT) ||
        (symbol.type == "string" && type != TokenType.CHAR && type != TokenType.QUOTE) ||
        (symbol.type == "boolean" && type != TokenType.BOOLEAN)
        ){
      throw new TypeError("Attempted to assign value of type " + type.value + " to symbol $ID of type " + symbol.type);
    }
  }
  
  // Does type checking
  void checkSymbolTypeAgainstToken(Token token, String ID){
    // Get the symbol
    Symbol leftHand = findSymbol(ID);
    
    // For handling symbols
    if(token.type == TokenType.ID){
      Symbol rightHand = findSymbol(token.value);
      if(rightHand != null){
        if(rightHand.type != leftHand.type){
          throw new TypeError("Attempted to assign value of type " + rightHand.type + " to symbol $ID of type " + leftHand.type);
        }
      }
      else{
        throw new SyntaxError("Undefined value " + token.value);
      }
    }
    // For handling normal variables
    else {
      checkSymbolTypeAgainstTokenType(token.type, ID);
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
    throw new SyntaxError("Identifier " + symbolID + " undefined");
  }
  
  void checkTypes(Token leftHand, Token rightHand){
    if(leftHand.type == TokenType.ID){
      Symbol left = findSymbol(leftHand.value);
      
      if(rightHand.type == TokenType.ID){
        Symbol right = findSymbol(rightHand.value);
        
        if(left.type != right.type){
          throw new TypeError("Symbol " + left.id + " of type " + left.type + " on line " + left.line.toString() + 
              " differs from symbol " + right.id + " of type " + right.type + " on line " + right.line.toString());
        }
      }
      else{
        checkSymbolTypeAgainstToken(rightHand, left.id);
      }
    }
    else if(rightHand.type == TokenType.ID){
      Symbol right = findSymbol(rightHand.value);
        
      checkSymbolTypeAgainstToken(leftHand, right.id);
    }
    else{
      if(leftHand.type != rightHand.type){
        throw new TypeError("Value \"" + leftHand.value + "\" of type " + leftHand.type.value + " on line " + leftHand.line.toString() + 
            " differs from value \"" + rightHand.value + "\" of type " + rightHand.type.value + " on line " + rightHand.line.toString());
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