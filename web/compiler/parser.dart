/* parser.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Implements recursive descent parsing to analyze tokens
 * */

import 'token.dart';
import 'symbol.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart'; // Enum lib
import '../util/logger_util.dart';
import '../util/exception_util.dart';

class Parser {

  // Logging
  static Logger log = LoggerUtil.createLogger('Parser');

  List<Token> tokens;
  Tree<dynamic> cst;
  // Simple for now
  List<CompilerSymbol> symbols = new List<CompilerSymbol>();
  num index = 0;
  num scope = 0;

  Parser(this.tokens);

  /* This is the main method for the Parser where all the magic happens */
  analyse() {
    log.info("Parser starting analysis...");
    if (!tokens.isEmpty) {

      // Instantiate CST
      cst = new Tree<dynamic>("Program", null);

      block(cst);

      Token token = popNextToken();

      if (token.type != TokenType.END) {
        ExceptionUtil.logAndThrow(new CompilerSyntaxError(
            "Expected END token, found type " + token.type.value + " on line " +
            token.line.toString()), log);
      }
      cst.dump();
      log.info("Parser finished analysis...");
    } else {
      log.warning("No tokens to parse, finished.");
    }
  }


  Tree<dynamic> addChild(dynamic data, Tree<dynamic> root) {
    Tree<dynamic> child = new Tree<dynamic>(data, root);
    root.addChild(child);
    return child;
  }

  void block(Tree<dynamic> currNode) {

    // Entering a block denotes a new sub tree
    currNode = addChild("Block", currNode);
    addChild(TokenType.OPEN_PAREN, currNode);

    // Entering a block denotes new scope
    scope++;

    statementList(currNode);

    addChild(TokenType.CLOSE_PAREN, currNode);

    // Exiting a block denotes new scope
    scope--;
  }

  void statementList(Tree<dynamic> currNode) {

    Token token = popNextToken();

    while (token.type != TokenType.CLOSE_BRACE) {
      // Entering a statement list denotes a new sub tree
      currNode = addChild("Statement List", currNode);

      if (token.type == TokenType.TYPE) {
        variableDeclaration(currNode);
      } else if (token.type == TokenType.ID) {
        assignmentStatement(currNode);
      } else if (token.type == TokenType.IF) {
        ifStatement(currNode);
      } else if (token.type == TokenType.WHILE) {
        whileStatement(currNode);
      } else if (token.type == TokenType.PRINT) {
        printStatement(currNode);
      } else if (token.type == TokenType.OPEN_BRACE) {
        block(currNode);
      } else {
        ExceptionUtil.logAndThrow(new CompilerSyntaxError(
            "Expected statement, found type " + token.type.value + " on line " +
            token.line.toString()), log);
      }

      // Change sentinel value
      token = popNextToken();
    }
  }

  /* STATEMENTS */
  void printStatement(Tree<dynamic> currNode) {
    log.info("Parsing print statement on line " + getLine());
    
    currNode = addChild("Print Statement", currNode);
    addChild("Print", currNode);

    expect(TokenType.OPEN_PAREN);
    addChild(TokenType.OPEN_PAREN, currNode);
    
    expression(currNode);
    expect(TokenType.CLOSE_PAREN);
    addChild(TokenType.CLOSE_PAREN, currNode);
  }

  /* ASSIGNMENT STATEMENTS */
  void assignmentStatement(Tree<dynamic> currNode) {
    log.info("Parsing assignment statement on line " + getLine());

    currNode = addChild("Assignment Statement", currNode);
    // Backtrack to parse id
    index--;
    idExpression(currNode);

    expect(TokenType.EQUALS);
    addChild(TokenType.EQUALS, currNode);

    expression(currNode);
  }

  /* IF STATEMENT */
  void ifStatement(Tree<dynamic> currNode) {
    log.info("Parsing if statement on line " + getLine());
    
    currNode = addChild("If Statement", currNode);

    condition(currNode);
    block(currNode);
  }

  /* WHILE STATEMENT */
  void whileStatement(Tree<dynamic> currNode) {
    log.info("Parsing while statement on line " + getLine());
    
    currNode = addChild("While Statement", currNode);

    condition(currNode);
    block(currNode);
  }

  /* VARIABLE DECLARATIONS */

  // Checks for an ID type token, creates the symbol, and adds it to the symbol table
  void variableDeclaration(Tree<dynamic> currNode) {
    log.info("Parsing variable declaration on line " + getLine());
    Token typeToken = getToken();

    currNode = addChild("Variable Declaration", currNode);
    Tree<dynamic> temp = addChild(typeToken.type, currNode);
    addChild(typeToken.value, temp);
    
    idExpression(currNode);
    
    // Get the ID token
    Token token = getToken();

    // Generate the symbol with both the ID and type from both tokens
    CompilerSymbol symbol = new CompilerSymbol(token.value, this.scope,
        token.line, typeToken.value);
    // Add this new symbol to our list of symbols
    this.symbols.add(symbol);
  }

  /* TYPE EXPRESSIONS */

  void expression(Tree<dynamic> currNode) {
    log.info("Parsing an expression on line " + getLine());

    currNode = addChild("Expression", currNode);

    if (isNextToken(TokenType.DIGIT)) {
      intExpression(currNode);
    } else if (isNextToken(TokenType.BOOLEAN)) {
      booleanExpression(currNode);
    } else if (isNextToken(TokenType.OPEN_PAREN)) {
      condition(currNode);
    } // Otherwise it must be a string
    else if (isNextToken(TokenType.QUOTE)) {
      stringExpression(currNode);
    } else if (isNextToken(TokenType.ID)) {
      idExpression(currNode);
    } else {
      print("idk");
    }
  }

  void intExpression(Tree<dynamic> currNode) {

    currNode = addChild("Int Expression", currNode);

    // Check for type int
    expect(TokenType.DIGIT);
    Tree<dynamic> temp = addChild(TokenType.DIGIT, currNode);
    addChild(getToken().value, temp);

    // Handle int operations aka +
    if (isNextToken(TokenType.INT_OP)) {
      expect(TokenType.INT_OP);
      expression(currNode);
    }
  }

  void booleanExpression(Tree<dynamic> currNode) {
    currNode = addChild("Boolean Expression", currNode);
    expect(TokenType.BOOLEAN); 
    
    Token token = getToken();
    addChild(token.value, currNode);
  }
  
  void stringExpression(Tree<dynamic> currNode) {
    
    Tree<dynamic> stringExpr = addChild("String Expression", currNode);
    
    // Opening Quote
    expect(TokenType.QUOTE);
    addChild(TokenType.QUOTE, stringExpr);
    
    Tree<dynamic> charList = addChild("CharList", stringExpr);
    // Iterate over the rest of the string
    while (peekNextToken() != null && (isNextToken(TokenType.CHAR) ||
        isNextToken(TokenType.SPACE))) {
      expectOneOf([TokenType.CHAR, TokenType.SPACE]);
      
      Token token = getToken();
      currNode = addChild(token.type, charList);
      addChild(token.value, currNode);
    }

    // Closing Quote
    expect(TokenType.QUOTE);
    addChild(TokenType.QUOTE, stringExpr);
  }
  
  void idExpression(Tree<dynamic> currNode) {
    
    currNode = addChild("ID Expression", currNode);
    expect(TokenType.ID);
    
    Token token = getToken();
    currNode = addChild("Char", currNode);
    addChild(token.value, currNode);
  }

  // Parses Conditionals (which are boolean expressions)
  void condition(Tree<dynamic> currNode) {
    
    Tree<dynamic> booleanExpr = addChild("Boolean Expression", currNode);
    
    // Handles conditionals within parenthesis
    if (peekNextToken().type == TokenType.OPEN_PAREN) {
      expect(TokenType.OPEN_PAREN);
      addChild(TokenType.OPEN_PAREN, booleanExpr);
      
      // Left Hand
      expression(booleanExpr);

      // Boolean expression
      expect(TokenType.BOOL_OP);
      Token token = getToken();
      Tree<dynamic> op = addChild(token.type, booleanExpr);
      addChild(token.value, op);

      // Right Hand
      expression(booleanExpr);
      
      expect(TokenType.CLOSE_PAREN);
      addChild(TokenType.CLOSE_PAREN, booleanExpr);
    } // Handles simple conditionals without parenthesis (true/false)
    else {
      booleanExpression(currNode);
    }
  }

  /* TOKEN HELPERS */

  /* This gets the next token and increments the index.
   * Named pop to imply mutating behavior.
   */
  Token popNextToken() {
    if (index < this.tokens.length - 1) {
      return this.tokens[++index];
    } else {
      return null;
    }
  }

  // Looks at the next token without incrementing the current token pointer
  Token peekNextToken() {
    if (index < this.tokens.length - 1) {
      return this.tokens[index + 1];
    } else {
      return null;
    }
  }

  // Gets the current token
  Token getToken() {
    if (index < this.tokens.length) {
      return this.tokens[index];
    } else {
      return null;
    }
  }

  // Gets the current token line
  String getLine() {
    return getToken().line.toString();
  }

  // Checks to see if the next token is what it should be
  void expect(TokenType type) {
    Token next = popNextToken();

    if (next.type != type) {
      ExceptionUtil.logAndThrow(new CompilerSyntaxError(
          "Expected token of type " + type.value + ", found type " + next.type.value +
          " on line " + next.line.toString()), log);
    }
  }

  // Checks to see if the next token is what it should be
  void expectOneOf(List<TokenType> types) {
    Token next = popNextToken();

    for (TokenType type in types) {
      if (next.type == type) {
        return;
      }
    }
    // In case not found
    ExceptionUtil.logAndThrow(new CompilerTypeError("Expected token of type " +
        types.toString() + ", found type " + next.type.value + " on line " +
        next.line.toString()), log);
  }

  /* Determines if the next token is the type of token
   * that we're looking for. Used for determing the next statement. 
   */
  bool isNextToken(TokenType type) {
    Token next = peekNextToken();
    if (next.type != type) {
      return false;
    }
    return true;
  }


}
