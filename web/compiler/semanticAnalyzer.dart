/* semanticAnalyzer.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

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

  /**
   *  This is the main method for the Semantic Analyzer where all the magic happens 
   */
  static analyze(Tree<dynamic> cst) {
    log.info("Semantic Analyzer starting analysis...");
    if (!cst.children.isEmpty) {

      // Instantiate AST
      Tree<dynamic> ast = convertProgram(cst, null);

      ast.dump();
      log.info("Semantic Analyzer finished analysis...");
      return ast;
    } else {
      log.warning("CST is empty, finished.");
    }
  }

  /**
   * Begins converting a program to an AST.
   */
  static Tree<dynamic> convertProgram(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> block = currNode.children.first;
    
    if (block.data == NonTerminal.BLOCK) {
      return convertBlock(block, parent);
    } else {
      print("unique exception");
    }
    return null;
  }

  static Tree<dynamic> convertBlock(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.BLOCK, parent);
    
    // Second item should be a statement list
    Tree<dynamic> statementList = currNode.children[1];
    
    if (statementList.data == NonTerminal.STATEMENT_LIST) {
      return convertStatementList(statementList, ast);
    } else {
      // Exception
    }
    return null;
  }

  static Tree<dynamic> convertStatementList(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    for (Tree<dynamic> tree in currNode.children) {
      switch (tree.data) {
        case NonTerminal.STATEMENT:
          return convertStatement(tree, parent);
          break;
        case NonTerminal.STATEMENT_LIST:
          return convertStatementList(tree, parent);
          break;
        default:
          print("failed to convert statement list");
          return null;
      }
    }
    return null;
  }

  static Tree<dynamic> convertStatement(Tree<dynamic> currNode, Tree<dynamic> parent)
      {
    // Statements only have one child
    Tree<dynamic> tree = currNode.children.first;
    switch (tree.data) {
      case NonTerminal.VARIABLE_DECLARATION:
        return convertVariableDeclaration(tree, parent);
        break;
      //      case NonTerminal.IF_STATEMENT:
      //        return convertIfStatement(tree, parent);
      //        break;
      //      case NonTerminal.WHILE_STATEMENT:
      //        return convertWhileStatement(tree, parent);
      //        break;
      case NonTerminal.PRINT_STATEMENT:
        return convertPrintStatement(tree, parent);
        break;
      default:
        print("failed to convert statement list");
        return null;
    }
  }
  
  static Tree<dynamic> convertVariableDeclaration(Tree<dynamic> currNode, Tree<dynamic> parent) {
    // We know that a variable declaration tree only has two children
    Tree<dynamic> type = currNode.children[0];
    Tree<dynamic> id = currNode.children[1];
    
    // New tree
    Tree<dynamic> variableDeclaration = new Tree<dynamic>(NonTerminal.VARIABLE_DECLARATION, parent);
    
    if(type.data == TokenType.TYPE){
      variableDeclaration.addChild(convertTypeDeclaration(type, variableDeclaration));
      print(id);
      if(id.data == NonTerminal.ID_EXPRESSION){
        variableDeclaration.addChild(convertIdExpression(id, variableDeclaration));
        return variableDeclaration;
      }
      else{
        print("meow");
      }
    }
    else{
      print("meow");
    }
    return null;
  }
  
  static Tree<dynamic> convertTypeDeclaration(Tree<dynamic> currNode, Tree<dynamic> parent) {
    Tree<dynamic> typeValue = currNode.children.first;
    
    if(typeValue.data != null) {
      return typeValue;
    }
    else{
      print("IM THROWING AN EXCEPTION");
    }
    return null;
  }

  static Tree<dynamic> convertPrintStatement(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.PRINT_STATEMENT, parent);

    // Print value always third element
    Tree<dynamic> value = currNode.children[2];

    if (value.data == NonTerminal.EXPRESSION) {
      ast.addChild(convertExpression(value, ast));
      return ast;
    } else {
      print("fuck");
    }
    return null;
  }

  static Tree<dynamic> convertExpression(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // An expression only has one child
    Tree<dynamic> expression = currNode.children.first;
    switch (expression.data) {
      case NonTerminal.ID_EXPRESSION:
        return convertIdExpression(expression, parent);
        break;
      default:
        print("failed to convert expression");
        return null;
    }
  }

  /**
   *  If we are in this situation we already know that 
   * the current tree node is an id expression. Forward to convertChar 
   **/
  static Tree<dynamic> convertIdExpression(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    return convertChar(currNode, parent);
  }

  static Tree<dynamic> convertChar(Tree<dynamic> cst, Tree<dynamic> parent) {
    // An ID expression only has one child
    Tree<dynamic> c = cst.children.first;
    if (c.data == TokenType.CHAR) {
      // The only child should be the value
      return c.children.first;
    } else {
      print("fuuu");
    }
    return null;
  }
}
