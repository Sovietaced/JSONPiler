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
import 'jumpTable.dart';
import 'exceptions.dart';
import '../util/exception_util.dart';


class CodeGenerator {

  // Logging
  static Logger log = LoggerUtil.createLogger('CodeGenerator');

  Tree<dynamic> ast;
  List<String> code;
  StaticTable staticTable;
  JumpTable jumpTable;
  num address = 0;

  CodeGenerator(this.ast) {
    this.code = new List<String>();
    this.staticTable = new StaticTable();
    this.jumpTable = new JumpTable();
  }

  void generateCode() {
    log.info("Code Generation starting...");
    // Recursively parse starting block
    parseBlock(this.ast);
    // Break
    brk();
    
    print(code.join());
    staticTable.dump();
    log.info("Code Generation finished...");
  }

  void parseBlock(Tree<dynamic> currNode) {
    log.info("Parsing a block");
    for (Tree<dynamic> statement in currNode.children) {
      print(statement.data);
      if (statement.data == NonTerminal.VARIABLE_DECLARATION) {
        generateVariableDeclaration(statement);
      } else if (statement.data == NonTerminal.ASSIGNMENT_STATEMENT) {
        generateAssignmentStatement(statement);
      } else if (statement.data == NonTerminal.PRINT_STATEMENT) {
        generatePrintStatement(statement);
      } else if (statement.data == NonTerminal.IF_STATEMENT) {
        generateIfStatement(statement);
      } else if (statement.data == NonTerminal.BLOCK) {
        parseBlock(statement);
      }
    }
  }

  void generateVariableDeclaration(Tree<dynamic> currNode) {
    log.info("Generating code for a variable declaration");
    String type = currNode.children[0].data;
    String id = currNode.children[1].data;

    // Make entry in static table
    String location = staticTable.addRow(id, address);

    // Load accumulator with 0
    lda_constant("0");
    sta(location);

  }

  /**
   * Generates code for an assignment statement.
   */
  void generateAssignmentStatement(Tree<dynamic> currNode) {
    log.info("Generating code for an assignment statement");
    String id = currNode.children[0].data;
    StaticTableRow leftRow = staticTable.getRow(id);

    //FIXME: handle advanced statements here
    String right = currNode.children[1].data;

    // Check if right hand side of assignment is an id
    if (staticTable.rowExists(right)) {
      StaticTableRow rightRow = staticTable.getRow(right);
      lda_memory(rightRow.location);
      sta(leftRow.location);
    } else {

      // Load accumulator with rightside of assignment
      lda_constant(right);
      sta(leftRow.location);
    }
  }

  /**
   * Generates code for a print statement.
   */
  void generatePrintStatement(Tree<dynamic> currNode) {
    log.info("Generating code for a print statement");
    //FIXME: handle advanced values here...
    String value = currNode.children.first.data;

    // Check if print value is an id
    if (staticTable.rowExists(value)) {
      StaticTableRow row = staticTable.getRow(value);
      // Load the memory location of the id into Y register
      ldy_memory(row.location);
    } else {
      //FIXME: other things besides integers could be here, like booleans
      ldy_constant(value);
    }

    // Load the X register with 1
    ldx_constant("1");
    // System call
    sys();
  }

  void generateIfStatement(Tree<dynamic> currNode) {
    log.info("Generating code for an if statement");
    //FIXME: handle advanced values here...
    String left = currNode.children[0].data;
    String right = currNode.children[2].data;
    Tree<dynamic> block = currNode.children[3];

    // Check if print value is an id
    if (staticTable.rowExists(left)) {
      StaticTableRow row = staticTable.getRow(left);
      // Load the memory location of the id into Y register
      ldx_memory(row.location);
    } else {
      //FIXME: other things besides integers could be here, like booleans
      ldx_constant(left);
    }

    // Check if print value is an id
    if (staticTable.rowExists(right)) {
      StaticTableRow row = staticTable.getRow(right);
      cpx(row.location);
    } else {
      //FIXME: other things besides integers could be here, like booleans
      cpx(right);
    }
    
    // Make new entry in the jump table
    String location = jumpTable.addRow();
    bne(location);
    
    num preBranch = address;
    parseBlock(block);
    num postBranch = address;
    
    // Calculate jump distance
    num distance = (postBranch - preBranch) + 1;
    jumpTable.setDistance(location, distance);
    
    //TODO: back patch jump distance
  }

  /**
   * Loads the accumulator with a constant
   */
  void lda_constant(String value) {
    log.info("Loading the accumulator with constant ${value}");
    insertString("A9");
    insertString(value);
  }
  
  /**
   * Loads the accumulator from memory
   */
  void lda_memory(String location) {
    log.info("Loading the accumulator from memory at ${location}");
    insertString("AD");
    insertString(location);
  }

  /**
   * Stores the accumulator in memory
   */
  void sta(String location) {
    log.info("Storing the accumulator in memory at ${location}");
    insertString("8D");
    insertString(location);
  }

  /**
   * Loads the X register with a constant
   */
  void ldx_constant(String value) {
    log.info("Loading the X register with constant ${value}");
    insertString("A2");
    insertString(value);
  }

  /**
   * Loads the X register from memory
   */
  void ldx_memory(String location) {
    log.info("Loading the X register from memory at ${location}");
    insertString("AE");
    insertString(location);
  }

  /**
   * Load the Y register with a constant
   */
  void ldy_constant(String value) {
    log.info("Loading the Y register with constant ${value}");
    insertString("A0");
    insertString(value);
  }

  /**
   * Load the Y register from memory
   */
  void ldy_memory(String location) {
    log.info("Loading the Y register from memory at ${location}");
    insertString("AC");
    insertString(location);
  }

  /**
   * Compare a byte in memory to the X register.
   * Sets the zero flag if equal.
   */
  void cpx(String location) {
    log.info("Comparing a byte in memory at ${location} to the X register");
    insertString("EC");
    insertString(location);
  }
  
  /**
   * Branch x bytes if Z flag = 0
   */
  void bne(String numBytes) {
    log.info("Branching ${numBytes} if Z flag = 0");
    insertString("D0");
    insertString(numBytes);
  }
  
  /**
   * Break
   */
  void brk() {
    log.info("Breaking");
    insertString("00");  
  }
  
  /**
   * System call
   */
  void sys() {
    log.info("Performing a system call");
    insertString("FF");
  }
  
  void backPatch(String location, String value) {
    
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
