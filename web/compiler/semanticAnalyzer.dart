/* semanticAnalyzer.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Recursively converts a CST to an AST. Performs type checking against literal values
 * and identifiers with the use of the symbol table. 
 * */

library SemanticAnalyzer;

import 'dart:html';
import 'token.dart';
import 'symbol.dart';
import 'exceptions.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart';
import '../util/logger_util.dart';
import '../util/exception_util.dart';

class SemanticAnalyzer {

  // Logging
  static Logger log = LoggerUtil.createLogger('SemanticAnalyzer');

  Tree<dynamic> cst;
  List<CompilerSymbol> symbols;
  num scope = 0;

  // Constructor
  SemanticAnalyzer(this.cst, this.symbols);
  
  
  /**
   *  This is the main method for the Semantic Analyzer where all the magic happens 
   */
  analyze() {
    log.info("Semantic Analyzer starting analysis...");
    if (!this.cst.children.isEmpty) {

      drawTree(this.cst, "cst");
      // Instantiate AST
      Tree<dynamic> ast = convertProgram(cst, null);

      log.info("Semantic Analyzer finished analysis... Dumping AST");
      ast.dump();
      drawTree(ast, "ast");
      return ast;
    } else {
      log.warning("CST is empty, finished analysis...");
    }
  }

  /**
   * Begins converting a program to an AST.
   */
  Tree<dynamic> convertProgram(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> block = currNode.children.first;
    return convertBlock(block, parent);
  }

  /**
   * Convert a CST block to an AST block
   */
  Tree<dynamic> convertBlock(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // Increment the scope
    scope++;

    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.BLOCK, parent, currNode.line);

    // Second item should be a statement list
    Tree<dynamic> statementList = currNode.children[1];
    for (Tree<dynamic> child in convertStatementList(statementList, ast)) {
      ast.addChild(child);
    }
    return ast;
  }

  /**
 * Converts a CST statement list to an AST statement list
 */
  List<Tree<dynamic>> convertStatementList(Tree<dynamic> currNode, Tree<dynamic> parent) {

    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

    for (Tree<dynamic> tree in currNode.children) {
      switch (tree.data) {
        case NonTerminal.STATEMENT:
          subTrees.add(convertStatement(tree, parent));
          break;
        case NonTerminal.STATEMENT_LIST:
          subTrees.addAll(convertStatementList(tree, parent));
          break;
        default:
          log.warning("failed to convert statement list");
          return null;
      }
    }
    return subTrees;
  }

  /**
   * Relays a CST statement to one of many AST statements
   */
  Tree<dynamic> convertStatement(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // Statements only have one child
    Tree<dynamic> tree = currNode.children.first;

    if (tree.data == NonTerminal.VARIABLE_DECLARATION) {
      return convertVariableDeclaration(tree, parent);
    } else if (tree.data == NonTerminal.ASSIGNMENT_STATEMENT) {
      return convertAssignmentStatement(tree, parent);
    } else if (tree.data == NonTerminal.IF_STATEMENT) {
      return convertIfStatement(tree, parent);
    } else if (tree.data == NonTerminal.WHILE_STATEMENT) {
      return convertWhileStatement(tree, parent);
    } else if (tree.data == NonTerminal.PRINT_STATEMENT) {
      return convertPrintStatement(tree, parent);
    } else if (tree.data == NonTerminal.BLOCK) {
      return convertBlock(tree, parent);
    } else {
      log.warning("failed to convert statement list");
      return null;
    }
  }

  /**
   * Convert a CST variable delcaration to an AST variable delcaration
   */
  Tree<dynamic> convertVariableDeclaration(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // We know that a variable declaration tree only has two children
    Tree<dynamic> type = currNode.children[0];
    Tree<dynamic> id = currNode.children[1];

    // New tree
    Tree<dynamic> variableDeclaration = new Tree<dynamic>(NonTerminal.VARIABLE_DECLARATION, parent, currNode.line);

    variableDeclaration.addChild(convertTypeDeclaration(type, variableDeclaration));
    variableDeclaration.addChild(convertIdExpression(id, variableDeclaration));

    return variableDeclaration;
  }

  /**
   * Convert a CST assignment statement to an AST assignment statement
   */
  Tree<dynamic> convertAssignmentStatement(Tree<dynamic> currNode, Tree<dynamic> parent) {
    log.info("Converting an asignment statement");

    // We know that an assignment statement tree only has two children
    Tree<dynamic> id = currNode.children[0];
    Tree<dynamic> value = currNode.children[2];

    // New tree
    Tree<dynamic> assignmentStatement = new Tree<dynamic>(NonTerminal.ASSIGNMENT_STATEMENT, parent, currNode.line);

    Tree<dynamic> idValue = convertIdExpression(id, assignmentStatement);
    assignmentStatement.addChild(idValue);

    List<Tree<dynamic>> expressionValues = convertExpression(value, assignmentStatement);
    assignmentStatement.addChildren(expressionValues);

    typeCheck(assignmentStatement.children);

    return assignmentStatement;
  }

  /**
   * Convert a CST if statement to an AST if statement
   */
  Tree<dynamic> convertIfStatement(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // New tree
    Tree<dynamic> ifStatement = new Tree<dynamic>(NonTerminal.IF_STATEMENT, parent, currNode.line);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.BOOLEAN_EXPRESSION) {
        ifStatement.addChildren(convertBooleanExpression(tree, ifStatement));
      } else if (tree.data == NonTerminal.BLOCK) {
        ifStatement.addChild(convertBlock(tree, ifStatement));
      }
    }
    return ifStatement;
  }

  /**
   * Convert a CST while statement to an AST while statement.
   */
  Tree<dynamic> convertWhileStatement(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // New tree
    Tree<dynamic> whileStatement = new Tree<dynamic>(NonTerminal.WHILE_STATEMENT, parent, currNode.line);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.BOOLEAN_EXPRESSION) {
        whileStatement.addChildren(convertBooleanExpression(tree, whileStatement));
      } else if (tree.data == NonTerminal.BLOCK) {
        whileStatement.addChild(convertBlock(tree, whileStatement));
      }
    }
    return whileStatement;
  }

  /**
   * Convert a CST type declaration to a AST type value
   */
  Tree<dynamic> convertTypeDeclaration(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> typeValue = currNode.children.first;
    return new Tree<dynamic>(typeValue.data, parent, currNode.line);
  }

  /**
   * Convert a CST print statement to an AST print statement
   */
  Tree<dynamic> convertPrintStatement(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.PRINT_STATEMENT, parent, currNode.line);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.EXPRESSION) {
        ast.addChildren(convertExpression(tree, ast));
      }
    }
    return ast;
  }

  /**
   * Converts a CST expression to one of many AST expressions
   */
  List<Tree<dynamic>> convertExpression(Tree<dynamic> currNode, Tree<dynamic> parent) {

    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

    for (Tree<dynamic> tree in currNode.children) {
      switch (tree.data) {
        case NonTerminal.ID_EXPRESSION:
          subTrees.add(convertIdExpression(tree, parent));
          break;
        case NonTerminal.INT_EXPRESSION:
          subTrees.addAll(convertIntExpression(tree, parent));
          break;
        case NonTerminal.BOOLEAN_EXPRESSION:
          subTrees.addAll(convertBooleanExpression(tree, parent));
          break;
        case NonTerminal.STRING_EXPRESSION:
          subTrees.add(convertStringExpression(tree, parent));
          break;
        default:
          log.warning("failed to convert expression");
          return null;
      }
    }
    return subTrees;
  }

  /**
   *  If we are in this situation we already know that 
   * the current tree node is an id expression. Forward to convertChar 
   **/
  Tree<dynamic> convertIdExpression(Tree<dynamic> currNode, Tree<dynamic> parent) {
    return convertChar(currNode, parent);
  }

  /**
   * Convert a CST int expression to an AST int expression
   */
  List<Tree<dynamic>> convertIntExpression(Tree<dynamic> currNode, Tree<dynamic> parent) {

    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == TokenType.DIGIT) {
        subTrees.add(convertDigit(tree, parent));
      } else if (tree.data == TokenType.INT_OP) {
        subTrees.add(convertIntOp(tree, parent));
      } else if (tree.data == NonTerminal.EXPRESSION) {
        subTrees.addAll(convertExpression(tree, parent));
      }
    }

    typeCheck(subTrees);

    return subTrees;
  }

  /**
   * Convert a CST boolean expression into an AST boolean expression
   */
  List<Tree<dynamic>> convertBooleanExpression(Tree<dynamic> currNode, Tree<dynamic> parent) {
    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == TokenType.BOOLEAN) {
        subTrees.add(convertBoolean(tree, parent));
      } else if (tree.data == TokenType.BOOL_OP) {
        subTrees.add(convertBoolOp(tree, parent));
      } else if (tree.data == NonTerminal.EXPRESSION) {
        subTrees.addAll(convertExpression(tree, parent));
      }
    }

    typeCheck(subTrees);

    return subTrees;
  }

  /**
   * Convert a CST string expression into an AST string expression
   */
  Tree<dynamic> convertStringExpression(Tree<dynamic> currNode, Tree<dynamic> parent) {

    // New tree
    Tree<dynamic> stringTree = new Tree<dynamic>(NonTerminal.STRING_EXPRESSION, parent, currNode.line);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.CHAR_LIST) {
        stringTree.addChildren(convertCharList(tree, stringTree));
      }
    }

    typeCheck(stringTree.children);

    return stringTree;
  }

  /**
   * Convert a CST digit to an AST digit value
   */
  Tree<dynamic> convertDigit(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent, value.line);
  }

  /**
   * Convert a CST charlist to an AST charlist (singular tree)
   */
  List<Tree<dynamic>> convertCharList(Tree<dynamic> currNode, Tree<dynamic> parent) {
    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == TokenType.CHAR || tree.data == TokenType.SPACE) {
        Tree<dynamic> value = tree.children.first;
        // The only child should be the value
        subTrees.add(new Tree<dynamic>(value.data, parent, value.line));
      }
    }
    return subTrees;
  }

  /**
   * Convert an int operation CST value to an int operation AST value
   */
  Tree<dynamic> convertIntOp(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent, value.line);
  }

  /**
   * Convert a boolean operation CST value to a boolean operation AST value
   */
  Tree<dynamic> convertBoolOp(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent, value.line);
  }

  /**
   * Convert a char CST value to a char AST value
   */
  Tree<dynamic> convertChar(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // An ID expression only has one child
    Tree<dynamic> c = currNode.children.first;
    Tree<dynamic> value = c.children.first;
    // The only child should be the value
    return new Tree<dynamic>(value.data, parent, value.line);
  }

  /**
   * Convert a boolean CST value to a boolean AST value
   */
  Tree<dynamic> convertBoolean(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent, value.line);
  }

  /**
   * Checks a list of values for type contiguencey. Assumes the first vaid value is the 
   * desired value to check against.
   */
  void typeCheck(List<Tree<dynamic>> right) {

    // Merge values
    List<Tree<dynamic>> clean = new List.from(right);

    // Remove any garbage we don't want to compare
    clean.removeWhere((item) => item.data == "==");
    clean.removeWhere((item) => item.data == "!=");
    clean.removeWhere((item) => item.data == "+");
    clean.removeWhere((item) => item.data is NonTerminal);

    // Reset values
    Tree<dynamic> left = clean.removeAt(0);
    right = clean;

    // Compare all values against the left most (first value)
    String type = determineType(left.data);
    if (type == "int") {
      ensureType(right, "int");
    } else if (type == "boolean") {
      ensureType(right, "boolean");
    } else {
      ensureType(right, "string");
    }
  }

  /**
   * Ensure that the list of values conforms to the specified type desired.
   */
  void ensureType(List<Tree<dynamic>> right, String desiredType) {

    for (Tree<dynamic> tree in right) {
      String value = tree.data.toString();
      String foundType = determineType(value);

      if (foundType != desiredType) {
        if (symbolExists(value)) {
          ExceptionUtil.logAndThrow(new CompilerTypeError("Identifier " + getSymbol(value).id + " on line " + tree.line + " is not of expected type $desiredType."), log);
        }
        ExceptionUtil.logAndThrow(new CompilerTypeError(tree.toString() + " on line " + tree.line + " is not of expected type $desiredType."), log);
      }
    }
  }

  /**
   * Determine the type of a value. Performs some really hacky tricks. Since AST values
   * are held as dynamic determining types is not so easy. First, symbols are checked. Then
   * the value is attempted to be parsed to a number. If an exception is thrown the value
   * is either a string or a boolean.
   */
  String determineType(String value) {

    // Symbol, easy
    if (symbolExists(value)) {
      CompilerSymbol symbol = getSymbol(value);
      return symbol.type;
    } // Literal value
    else {
      // Check if int
      try {
        num.parse(value);
        return "int";
        // If an exception is thrown the value is either a string or a boolean
      } on FormatException {
        if (value == "true" || value == "false") {
          return "boolean";
        } else {
          return "string";
        }
      }
    }
  }

  /**
   * Gets all instances of a symbol from the symbol table.
   */
  CompilerSymbol getSymbol(String symbol) {

    for (CompilerSymbol s in this.symbols) {
      if (s.id == symbol && s.scope == scope) {
        return s;
      }
    }
    log.warning("Compiler can't find symbol");
    return null;
  }

  /**
   * Checks if the specified symbol exists
   */
  bool symbolExists(String symbol) {
    for (CompilerSymbol s in this.symbols) {
      if (s.id == symbol) {
        return true;
      }
    }
    return false;
  }

  /**
   * Replaces a div on screen with a syntree string.
   */
  void drawTree(Tree<dynamic> tree, String id) {
    (querySelector("#$id")).appendText(tree.syntrify());
  }
}
