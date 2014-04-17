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
  static Tree<dynamic> convertProgram(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    Tree<dynamic> block = currNode.children.first;

    if (block.data == NonTerminal.BLOCK) {
      return convertBlock(block, parent);
    } else {
      print("unique exception");
    }
    return null;
  }

  static Tree<dynamic> convertBlock(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.BLOCK, parent);

    // Second item should be a statement list
    Tree<dynamic> statementList = currNode.children[1];
    if (statementList.data == NonTerminal.STATEMENT_LIST) {
      for (Tree<dynamic> child in convertStatementList(statementList, ast)) {
        ast.addChild(child);
      }
      return ast;
    } else {
      print("trololol");
    }
    return null;
  }

  static List<Tree<dynamic>> convertStatementList(Tree<dynamic>
      currNode, Tree<dynamic> parent) {

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
          print("failed to convert statement list");
          return null;
      }
    }
    return subTrees;
  }

  static Tree<dynamic> convertStatement(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // Statements only have one child
    Tree<dynamic> tree = currNode.children.first;
    print(tree.data);
    switch (tree.data) {
      case NonTerminal.VARIABLE_DECLARATION:
        return convertVariableDeclaration(tree, parent);
        break;
      case NonTerminal.ASSIGNMENT_STATEMENT:
        return convertAssignmentStatement(tree, parent);
        break;
      case NonTerminal.IF_STATEMENT:
        return convertIfStatement(tree, parent);
        break;
      case NonTerminal.WHILE_STATEMENT:
        return convertWhileStatement(tree, parent);
        break;
      case NonTerminal.PRINT_STATEMENT:
        return convertPrintStatement(tree, parent);
        break;
      case NonTerminal.BLOCK:
        return convertBlock(tree, parent);
        break;
      default:
        print("failed to convert statement list");
        return null;
    }
  }

  static Tree<dynamic> convertVariableDeclaration(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    // We know that a variable declaration tree only has two children
    Tree<dynamic> type = currNode.children[0];
    Tree<dynamic> id = currNode.children[1];

    // New tree
    Tree<dynamic> variableDeclaration = new Tree<dynamic>(
        NonTerminal.VARIABLE_DECLARATION, parent);

    if (type.data == TokenType.TYPE) {
      variableDeclaration.addChild(convertTypeDeclaration(type,
          variableDeclaration));
      if (id.data == NonTerminal.ID_EXPRESSION) {
        variableDeclaration.addChild(convertIdExpression(id, variableDeclaration
            ));
        return variableDeclaration;
      } else {
        print("meow");
      }
    } else {
      print("meow");
    }
    return null;
  }

  static Tree<dynamic> convertAssignmentStatement(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    // We know that an assignment statement tree only has two children
    Tree<dynamic> id = currNode.children[0];
    Tree<dynamic> value = currNode.children[2];

    if (currNode.data == NonTerminal.ASSIGNMENT_STATEMENT) {
      // New tree
      Tree<dynamic> assignmentStatement = new Tree<dynamic>(
          NonTerminal.ASSIGNMENT_STATEMENT, parent);

      if (id.data == NonTerminal.ID_EXPRESSION) {
        assignmentStatement.addChild(convertIdExpression(id, assignmentStatement
            ));
        if (value.data == NonTerminal.EXPRESSION) {
          assignmentStatement.addChildren(convertExpression(value,
              assignmentStatement));
          return assignmentStatement;
        } else {

        }
      } else {

      }
    } else {
      // throw an error
    }
    return null;
  }

  static Tree<dynamic> convertIfStatement(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // New tree
    Tree<dynamic> ifStatement = new Tree<dynamic>(NonTerminal.IF_STATEMENT,
        parent);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.BOOLEAN_EXPRESSION) {
        ifStatement.addChildren(convertBooleanExpression(tree, ifStatement));
      } else if (tree.data == NonTerminal.BLOCK) {
        ifStatement.addChild(convertBlock(tree, ifStatement));
      }
    }
    ifStatement.dump();
    return ifStatement;
  }

  static Tree<dynamic> convertWhileStatement(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    // New tree
    Tree<dynamic> whileStatement = new Tree<dynamic>(
        NonTerminal.WHILE_STATEMENT, parent);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.BOOLEAN_EXPRESSION) {
        whileStatement.addChildren(convertBooleanExpression(tree, whileStatement
            ));
      } else if (tree.data == NonTerminal.BLOCK) {
        whileStatement.addChild(convertBlock(tree, whileStatement));
      }
    }
    return whileStatement;
  }

  static Tree<dynamic> convertTypeDeclaration(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    Tree<dynamic> typeValue = currNode.children.first;
    return new Tree<dynamic>(typeValue.data, parent);
  }

  static Tree<dynamic> convertPrintStatement(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    Tree<dynamic> ast = new Tree<dynamic>(NonTerminal.PRINT_STATEMENT, parent);

    for (Tree<dynamic> tree in currNode.children) {
      if (tree.data == NonTerminal.EXPRESSION) {
        ast.addChildren(convertExpression(tree, ast));
      }
    }
    return ast;
  }

  static List<Tree<dynamic>> convertExpression(Tree<dynamic>
      currNode, Tree<dynamic> parent) {

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
          print("failed to convert statement list");
          return null;
      }
    }
    return subTrees;
  }

  /**
   *  If we are in this situation we already know that 
   * the current tree node is an id expression. Forward to convertChar 
   **/
  static Tree<dynamic> convertIdExpression(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    return convertChar(currNode, parent);
  }

  static List<Tree<dynamic>> convertIntExpression(Tree<dynamic>
      currNode, Tree<dynamic> parent) {

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
    return subTrees;
  }

  static List<Tree<dynamic>> convertBooleanExpression(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
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
    return subTrees;
  }
  
  static Tree<dynamic> convertStringExpression(Tree<dynamic>
      currNode, Tree<dynamic> parent) {
    
// New tree
 Tree<dynamic> stringTree = new Tree<dynamic>(
     NonTerminal.STRING_EXPRESSION, parent);
    
    for (Tree<dynamic> tree in currNode.children) {
      print(tree.data);
      if (tree.data == NonTerminal.CHAR_LIST) {
        stringTree.addChildren(convertCharList(tree, stringTree));
      }
    }
    return stringTree;
  }

  static Tree<dynamic> convertDigit(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent);
  }
  
  static List<Tree<dynamic>> convertCharList(Tree<dynamic> currNode, Tree<dynamic> parent) {
    List<Tree<dynamic>> subTrees = new List<Tree<dynamic>>();

        for (Tree<dynamic> tree in currNode.children) {
          if (tree.data == TokenType.CHAR) {
            Tree<dynamic> value = tree.children.first;
                  // The only child should be the value
                  subTrees.add(new Tree<dynamic>(value.data, parent));
          }
        }
        return subTrees;
  }

  static Tree<dynamic> convertIntOp(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent);
  }

  static Tree<dynamic> convertBoolOp(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    // An ID expression only has one child
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent);
  }

  static Tree<dynamic> convertChar(Tree<dynamic> currNode, Tree<dynamic> parent)
      {
    // An ID expression only has one child
    Tree<dynamic> c = currNode.children.first;
    if (c.data == TokenType.CHAR) {
      Tree<dynamic> value = c.children.first;
      // The only child should be the value
      return new Tree<dynamic>(value.data, parent);
    } else {
      print("fuuu");
    }
    return null;
  }

  static Tree<dynamic> convertBoolean(Tree<dynamic> currNode, Tree<dynamic>
      parent) {
    Tree<dynamic> value = currNode.children.first;
    return new Tree<dynamic>(value.data, parent);
  }
}
