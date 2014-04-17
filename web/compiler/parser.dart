/* parser.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Implements recursive descent parsing to analyze tokens
 * */

import 'token.dart';
import 'symbol.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart'; 
import '../util/logger_util.dart';
import '../util/exception_util.dart';

class Parser {

  // Logging
  static Logger log = LoggerUtil.createLogger('Parser');

  List<Token> tokens;
  Tree<dynamic> cst;
  List<CompilerSymbol> symbols = new List<CompilerSymbol>();
  num index = 0;
  num scope = 0;

  Parser(this.tokens);

  /**
   *  This is the main method for the Parser where all the magic happens 
   */
  analyse() {
    log.info("Parser starting analysis...");
    if (!tokens.isEmpty) {

      // Instantiate CST
      cst = new Tree<dynamic>(NonTerminal.PROGRAM, null);

      // Load block with root
      block(cst);

      Token token = popNextToken();

      if (token.type != TokenType.END) {
        ExceptionUtil.logAndThrow(new CompilerSyntaxError(
            "Expected END token, found type " + token.type.value + " on line " +
            token.line.toString()), log);
      }
      cst.dump();
      log.info("Parser finished analysis...");
      return cst;
    } else {
      log.warning("No tokens to parse, finished.");
    }
  }

  /**
   * Helper to add a new child tree to the specified root tree
   */
  Tree<dynamic> addChild(dynamic data, Tree<dynamic> root) {
    Tree<dynamic> child = new Tree<dynamic>(data, root);
    root.addChild(child);
    return child;
  }

  /**
   * Parses a block 
   */
  void block(Tree<dynamic> currNode) {
    log.info("Parsing block on line " + getLine());
    // Entering a block denotes a new sub tree
    currNode = addChild(NonTerminal.BLOCK, currNode);
    addChild(TokenType.OPEN_BRACE, currNode);

    // Entering a block denotes new scope
    scope++;

    statementList(currNode);

    addChild(TokenType.CLOSE_BRACE, currNode);

    // Exiting a block denotes new scope
    scope--;
  }
  
  void expectBlock(Tree<dynamic> currNode) {
    index++;
    block(currNode);
  }

  /**
   * Parses a statement list
   */
  void statementList(Tree<dynamic> currNode) {

    Token token = popNextToken();

    while (token.type != TokenType.CLOSE_BRACE) {
      // Entering a statement list denotes a new sub tree
      currNode = addChild(NonTerminal.STATEMENT_LIST, currNode);
      if (token.type == TokenType.TYPE) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        variableDeclaration(temp);
      } else if (token.type == TokenType.ID) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        assignmentStatement(temp);
      } else if (token.type == TokenType.IF) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        ifStatement(temp);
      } else if (token.type == TokenType.WHILE) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        whileStatement(temp);
      } else if (token.type == TokenType.PRINT) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        printStatement(temp);
      } else if (token.type == TokenType.OPEN_BRACE) {
        Tree<dynamic> temp = addChild(NonTerminal.STATEMENT, currNode);
        block(temp);
      } else {
        ExceptionUtil.logAndThrow(new CompilerSyntaxError(
            "Expected statement, found type " + token.type.value + " on line " +
            token.line.toString()), log);
      }

      // Change sentinel value
      token = popNextToken();
    }
  }

  /**
   * Parses a print statement
   */
  void printStatement(Tree<dynamic> currNode) {
    log.info("Parsing print statement on line " + getLine());
    
    currNode = addChild(NonTerminal.PRINT_STATEMENT, currNode);
    addChild("Print", currNode);

    expect(TokenType.OPEN_PAREN);
    addChild(TokenType.OPEN_PAREN, currNode);

    expression(currNode);
    expect(TokenType.CLOSE_PAREN);
    addChild(TokenType.CLOSE_PAREN, currNode);
  }

  /**
   * Parses an assignment statement
   */
  void assignmentStatement(Tree<dynamic> currNode) {
    log.info("Parsing assignment statement on line " + getLine());
    
    currNode = addChild(NonTerminal.ASSIGNMENT_STATEMENT, currNode);
    // Backtrack to parse id
    index--;
    idExpression(currNode);

    expect(TokenType.EQUALS);
    addChild(TokenType.EQUALS, currNode);

    expression(currNode);
  }

  /**
   * Parses an if statement
   */
  void ifStatement(Tree<dynamic> currNode) {
    log.info("Parsing if statement on line " + getLine());
    
    currNode = addChild(NonTerminal.IF_STATEMENT, currNode);

    booleanExpression(currNode);
    
    expectBlock(currNode);
  }

  /**
   * Parses a while statement
   */
  void whileStatement(Tree<dynamic> currNode) {
    log.info("Parsing while statement on line " + getLine());
    
    currNode = addChild(NonTerminal.WHILE_STATEMENT, currNode);

    booleanExpression(currNode);
    
    expectBlock(currNode);
  }

  /**
   * Parses a variable declaration
   */
  void variableDeclaration(Tree<dynamic> currNode) {
    log.info("Parsing a variable declaration on line " + getLine());
    Token typeToken = getToken();
    
    currNode = addChild(NonTerminal.VARIABLE_DECLARATION, currNode);
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

  /**
   * Parses type expressions
   */
  void expression(Tree<dynamic> currNode) {
    log.info("Parsing an expression on line " + getLine());

    currNode = addChild(NonTerminal.EXPRESSION, currNode);

    if (isNextToken(TokenType.DIGIT)) {
      intExpression(currNode);
    } else if (isNextToken(TokenType.BOOLEAN) || isNextToken(
        TokenType.OPEN_PAREN)) {
      booleanExpression(currNode);
    } // Otherwise it must be a string
    else if (isNextToken(TokenType.QUOTE)) {
      stringExpression(currNode);
    } else if (isNextToken(TokenType.ID)) {
      idExpression(currNode);
    } else {
      print("idk");
    }
  }

  /**
   * Parses an int expression
   */
  void intExpression(Tree<dynamic> currNode) {
    log.info("Parsing an int expression on line " + getLine());

    currNode = addChild(NonTerminal.INT_EXPRESSION, currNode);

    // Check for type int
    expect(TokenType.DIGIT);
    Tree<dynamic> temp = addChild(TokenType.DIGIT, currNode);
    addChild(getToken().value, temp);

    // Handle int operations aka +
    if (isNextToken(TokenType.INT_OP)) {
      expect(TokenType.INT_OP);
      
      Token token = getToken();
      Tree<dynamic> temp = addChild(token.type, currNode);
      addChild(token.value, temp);
      
      expression(currNode);
    }
  }

  /**
   * Parses a boolean expression
   */
  void booleanExpression(Tree<dynamic> currNode) {
    log.info("Parsing a boolean expression on line " + getLine());

    Tree<dynamic> booleanExpr = addChild(NonTerminal.BOOLEAN_EXPRESSION, currNode);

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
      expect(TokenType.BOOLEAN); 
      Token token = getToken();
      Tree<dynamic> temp = addChild(token.type, booleanExpr);
      addChild(token.value, temp);
    }
  }

  /**
   * Parses a string expression
   */
  void stringExpression(Tree<dynamic> currNode) {
    log.info("Parsing a string expression on line " + getLine());

    Tree<dynamic> stringExpr = addChild(NonTerminal.STRING_EXPRESSION, currNode);

    // Opening Quote
    expect(TokenType.QUOTE);
    addChild(TokenType.QUOTE, stringExpr);

    // Iterate over the rest of the string
    Tree<dynamic> charList = addChild(NonTerminal.CHAR_LIST, stringExpr);
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

  /**
   * Parses an identifier expression
   */
  void idExpression(Tree<dynamic> currNode) {
    log.info("Parsing an id expression on line " + getLine());
    
    currNode = addChild(NonTerminal.ID_EXPRESSION, currNode);
    expect(TokenType.ID);

    Token token = getToken();
    currNode = addChild(TokenType.CHAR, currNode);
    addChild(token.value, currNode);
  }

  /** 
   * This gets the next token and increments the index.
   * Named pop to imply mutating behavior.
   */
  Token popNextToken() {
    if (index < this.tokens.length - 1) {
      return this.tokens[++index];
    } else {
      return null;
    }
  }

  /**
   *  Looks at the next token without incrementing the current token pointer
   */
  Token peekNextToken() {
    if (index < this.tokens.length - 1) {
      return this.tokens[index + 1];
    } else {
      return null;
    }
  }

  /**
   *  Gets the current token
   */
  Token getToken() {
    if (index < this.tokens.length) {
      return this.tokens[index];
    } else {
      return null;
    }
  }

  /**
   *  Gets the current token line
   */
  String getLine() {
    return getToken().line.toString();
  }

  /**
   *  Checks to see if the next token is what it should be
   */
  void expect(TokenType type) {
    Token next = popNextToken();

    if (next.type != type) {
      ExceptionUtil.logAndThrow(new CompilerSyntaxError(
          "Expected token of type " + type.value + ", found type " + next.type.value +
          " on line " + next.line.toString()), log);
    }
  }

  /**
   *  Checks to see if the next token is what it should be
   */
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

  /**
   * Determines if the next token is the type of token
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
