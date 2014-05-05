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
    generateBlock(this.ast);
    log.info("Code Generation finished...");
  }

  void generateBlock(Tree<dynamic> currNode) {
    for (Tree<dynamic> statement in currNode.children) {
      if (statement.data == NonTerminal.VARIABLE_DECLARATION) {
        generateVariableDeclaration(statement);
      }
    }
    print(code);
    staticTable.dump();
  }

  void generateVariableDeclaration(Tree<dynamic> currNode) {
    String type = currNode.children[0].data;
    String id = currNode.children[1].data;

    // Make entry in static table
    String location = staticTable.addRow(id, address);

    // Generate code
    lda(0, location);

  }

  void generateAssignmentStatement(Tree<dynamic> currNode) {
    String id = currNode.children[0].data;
    //FIXME: handle advanced statements here
    String value = currNode.children[1].data;

    // Make entry in static table
  }

  void lda(int value, String location) {
    code.add("A9");
    address++;
    addNumToHex(value);
    code.add("8D");
    address++;
    insertString(location);
  }

  void addNumToHex(int value) {
    String number = value.toRadixString(16);

    // Make string even
    if (number.length % 2 != 0) {
      if(number.length == 1) {
        number = "0" + number;
      }
      else {
        number = number.substring(0, number.length - 2) + "0" + number[number.length - 1];
      }
    }

    for (var i = 0; i < number.length; i = i + 2) {
      code.add(number[i] + number[i + 1]);
    }
  }

  void insertString(String value) {

    // Make string even
    if (value.length % 2 != 0) {
      if(value.length == 1){
        value = "0" + value;
      }
      else {
        value = value.substring(0, value.length - 2) + "0" + value[value.length - 1];
      }
    }

    for (var i = 0; i < value.length; i = i + 2) {
      code.add(value[i] + value[i + 1]);
    }
  }
}
