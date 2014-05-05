/* codeGenerator.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

library codeGenerator;

import '../util/logger_util.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart';
import 'token.dart';
import 'symbol.dart';
import 'staticTable.dart';
import 'exceptions.dart';
import '../util/exception_util.dart';


class CodeGenerator {

  // Logging
  static Logger log = LoggerUtil.createLogger('CodeGenerator');

  Tree<dynamic> ast;
  List<String> code;
  StaticTable staticTable;
  num address = 0;

  CodeGenerator(this.ast) {
    this.code = new List<String>();
    this.staticTable = new StaticTable();
  }

  void generateCode() {
    log.info("Code Generation starting...");
    parseBlock(this.ast);
    log.info("Code Generation finished...");
  }

  void parseBlock(Tree<dynamic> currNode) {
    for (Tree<dynamic> statement in currNode.children) {
      if (statement.data == NonTerminal.VARIABLE_DECLARATION) {
        generateVariableDeclaration(statement);
      } else if (statement.data == NonTerminal.ASSIGNMENT_STATEMENT) {
        generateAssignmentStatement(statement);
      }
    }
    print(code.join());
    staticTable.dump();
  }

  void generateVariableDeclaration(Tree<dynamic> currNode) {
    String type = currNode.children[0].data;
    String id = currNode.children[1].data;

    // Make entry in static table
    String location = staticTable.addRow(id, address);

    // Load accumulator with 0
    lda("0", location);

  }

  /**
   * Generates code for an assignment statement.
   */
  void generateAssignmentStatement(Tree<dynamic> currNode) {
    String id = currNode.children[0].data;
    Row leftRow = staticTable.getRow(id);

    //FIXME: handle advanced statements here
    String right = currNode.children[1].data;

    // Check if right hand side of assignment is an id
    if (staticTable.rowExists(right)) {
      Row rightRow = staticTable.getRow(right);
      lda(rightRow.location, leftRow.location);
    } else {

      // Load accumulator with rightside of assignment
      lda(right, leftRow.location);
    }
  }

  /**
   * Loads the accumulator with a value
   */
  void lda(String value, String location) {
    insertString("A9");
    insertString(value);
    insertString("8D");
    insertString(location);
  }

  void addNumToHex(int value) {
    String number = value.toRadixString(16);

    // Make string even
    if (number.length % 2 != 0) {
      if (number.length == 1) {
        number = "0" + number;
      } else {
        number = number.substring(0, number.length - 2) + "0" + number[number.length - 1];
      }
    }

    for (var i = 0; i < number.length; i = i + 2) {
      code.add(number[i] + number[i + 1]);
    }
  }

  /**
   * Simply adds the string value to the code in byte formation.
   */
  void insertString(String value) {

    // Make string even
    if (value.length % 2 != 0) {
      if (value.length == 1) {
        value = "0" + value;
      } else {
        value = value.substring(0, value.length - 2) + "0" + value[value.length - 1];
      }
    }

    for (var i = 0; i < value.length; i = i + 2) {
      code.add(value[i] + value[i + 1]);
      address++;
    }
  }
}
