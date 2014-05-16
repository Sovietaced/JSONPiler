/* codeGenerator.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

library codeGenerator;

import '../util/logger_util.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart';
import 'symbol.dart';
import 'staticTable.dart';
import 'jumpTable.dart';
import 'exceptions.dart';
import '../util/exception_util.dart';
import '../util/conversion_util.dart';


class CodeGenerator {

  // Logging
  static Logger log = LoggerUtil.createLogger('CodeGenerator');
  static num MAX_MEMORY = 256;

  Tree<dynamic> ast;
  List<String> code;
  StaticTable staticTable;
  JumpTable jumpTable;
  int address = 0;
  num scope = -1;


  CodeGenerator(this.ast) {
    this.code = new List<String>(MAX_MEMORY);
    this.staticTable = new StaticTable();
    this.jumpTable = new JumpTable();
  }

  String generateCode() {
    log.info("Code Generation starting...");
    // Recursively parse starting block
    parseBlock(this.ast);
    // Break
    brk();

    generateStaticVariables();

    // Set null values in array to zero
    setNullToZero();

    String output = "";
    for (var i = 0; i < this.code.length; i = i + 16) {
      output = output + this.code.sublist(i, i + 16).join(" ") + "\n";
    }
    log.info("Code Generation finished...");

    print(output);
    return output;
  }

  void setNullToZero() {
    for (var i = 0; i < MAX_MEMORY; i++) {
      if (this.code[i] == null) {
        this.code[i] = "00";
      }
    }
  }

  void parseBlock(Tree<dynamic> currNode) {
    log.info("Parsing a block");

    // Increment scope
    scope++;

    for (Tree<dynamic> statement in currNode.children) {
      if (statement.data == NonTerminal.VARIABLE_DECLARATION) {
        generateVariableDeclaration(statement);
      } else if (statement.data == NonTerminal.ASSIGNMENT_STATEMENT) {
        generateAssignmentStatement(statement);
      } else if (statement.data == NonTerminal.PRINT_STATEMENT) {
        generatePrintStatement(statement);
      } else if (statement.data == NonTerminal.IF_STATEMENT) {
        generateIfStatement(statement);
      } else if (statement.data == NonTerminal.WHILE_STATEMENT) {
        generateWhileStatement(statement);
      } else if (statement.data == NonTerminal.BLOCK) {
        parseBlock(statement);
      }
    }

    // Decriment scope
    scope--;
  }

  void generateVariableDeclaration(Tree<dynamic> currNode) {
    log.info("Generating code for a variable declaration");
    String type = currNode.children[0].data;
    String id = currNode.children[1].data;

    if (type == StaticTable.TYPE_INT) {
      // Make entry in static table
      String location = staticTable.addRow(id, StaticTable.TYPE_INT, scope);

      // Load accumulator with 0
      lda_constant("0");
      sta(location);
    } else if (type == StaticTable.TYPE_STRING) {
      // Make entry in static table
      staticTable.addRow(id, StaticTable.TYPE_STRING, scope);
    } else if (type == StaticTable.TYPE_BOOLEAN) {
      // Make entry in static table
      String location = staticTable.addRow(id, StaticTable.TYPE_BOOLEAN, scope);

      // Load accumulator with 0
      lda_constant("0");
      sta(location);
    }

  }

  /**
   * Generates code for an assignment statement.
   */
  void generateAssignmentStatement(Tree<dynamic> currNode) {
    log.info("Generating code for an assignment statement");
    String id = currNode.children[0].data;
    StaticTableRow leftRow = staticTable.getRow(id, scope);

    // Chop id off list
    currNode.children.removeAt(0);

    //FIXME: handle advanced statements here
    String right = currNode.children[0].data;

    // Check if right hand side of assignment is an id
    if (staticTable.rowExists(right, scope)) {
      StaticTableRow rightRow = staticTable.getRow(right, scope);
      lda_memory(rightRow.location);
      sta(leftRow.location);

      leftRow.setValue(rightRow.value);
    } else {

      // Record value for helping later
      leftRow.setValue(right);

      if (leftRow.type == StaticTable.TYPE_INT) {

        right = combineIntExpression(currNode.children);
        leftRow.setValue(right);

        sta(leftRow.location);

      } else if (leftRow.type == StaticTable.TYPE_STRING) {
        leftRow.setValue(right);
        String hexString = ConversionUtil.stringToHex(right);

        // Write the hexString to heap, get address back
        int index = writeDataToHeap(hexString);

        // Convert address to hex string and store static pointer
        String hexIndex = ConversionUtil.numToHex(index);
        lda_constant(hexIndex);
        sta(leftRow.location);

      } else if (leftRow.type == StaticTable.TYPE_BOOLEAN) {

        right = combineBooleanExpression(currNode.children);
        leftRow.setValue(right);
        lda_constant(right);
        sta(leftRow.location);
      }
    }
  }

  /**
   * Shrinks integer expressions down to one value
   */
  String combineIntExpression(List<Tree<dynamic>> intExpression) {

    intExpression.removeWhere((item) => item.data == "+");

    if (intExpression.length > 1) {
      int sum = 0;
      // Set sum to zero
      lda_constant("0");
      for (Tree<dynamic> tree in intExpression) {
        String data = tree.data;
        if (staticTable.rowExists(data, scope)) {
          StaticTableRow row = staticTable.getRow(data, scope);
          sum = sum + int.parse(row.value);

          // Add to the accumulator!
          adc(row.location);
        } else {
          int value = int.parse(data);
          sum = sum + value;
          int index = findAvailableHeapMemory();
          String hex = ConversionUtil.numToHex(value);
          this.code[index] = ConversionUtil.numToHex(value);

          String validAddress = ConversionUtil.numToHex(index);
          validAddress = ConversionUtil.toLittleEndian(validAddress, 4);

          // Add to the accumulator!
          adc(validAddress);
        }
      }

      return ConversionUtil.numToHex(sum);
    } else {

      String value = intExpression.first.data;
      lda_constant(value);
      return value;
    }
  }

  /**
   * Shrinks boolean expressions down to one value
   */
  String combineBooleanExpression(List<Tree<dynamic>> booleanExpression) {

    booleanExpression.removeWhere((item) => item.data == "==");

    if (booleanExpression.length > 1) {
      bool start = null;

      if (booleanExpression.first.data == "true") {
        start = true;
      } else {
        start = false;
      }

      for (Tree<dynamic> tree in booleanExpression) {
        String data = tree.data;

        if (staticTable.rowExists(data, scope)) {
          StaticTableRow row = staticTable.getRow(data, scope);
          data = row.value;
        }

        if (data == "true") {
          start = start == true;
        } else {
          start = start == false;
        }
      }

      if (start == true) {
        return ConversionUtil.booleanToHex("true");
      } else {
        return ConversionUtil.booleanToHex("false");
      }

    } else {
      return ConversionUtil.booleanToHex(booleanExpression.first.data);
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
    if (staticTable.rowExists(value, scope)) {
      StaticTableRow row = staticTable.getRow(value, scope);
      // Load the memory location of the id into Y register
      ldy_memory(row.location);

      if (row.type == StaticTable.TYPE_STRING) {
        // Load 2 to print null terminated string
        ldx_constant("2");
      } else {
        // Load 1 to print integer value
        ldx_constant("1");
      }
    } else {
      ldy_constant(value);
      // Load 1 to print integer value
      ldx_constant("1");
    }

    // System call
    sys();
  }

  void generateIfStatement(Tree<dynamic> currNode) {
    log.info("Generating code for an if statement");

    Tree<dynamic> block = handleComparison(currNode);

    if (block != null) {
      // Make new entry in the jump table
      String location = jumpTable.addRow();
      bne(location);

      int preBranch = address;
      parseBlock(block);
      int postBranch = address;

      // Calculate jump distance
      int distance = (postBranch - preBranch);
      jumpTable.setDistance(location, distance);

      String hexDistance = ConversionUtil.numToHex(distance);
      backPatch(location, hexDistance);
    }
  }

  void generateWhileStatement(Tree<dynamic> currNode) {

    int preWhile = address;

    Tree<dynamic> block = handleComparison(currNode);

    if (block != null) {
      // Make new entry in the jump table
      String branchForward = jumpTable.addRow();
      bne(branchForward);

      int preBranch = address;
      parseBlock(block);

      // Reset the Z Flag so we always branch back to the while loop
      resetZFlag();
      String branchBackward = jumpTable.addRow();
      bne(branchBackward);

      int postWhile = address;

      // Calculate jump backwards distance
      int whileDistance = (postWhile - preWhile);
      jumpTable.setDistance(branchBackward, whileDistance);

      // Wrap around to branch backwards
      whileDistance = MAX_MEMORY - whileDistance;
      String backwardsDistance = ConversionUtil.numToHex(whileDistance);
      backPatch(branchBackward, backwardsDistance);

      int postBranch = address;

      // Calculate jump distance
      int distance = (postBranch - preBranch);
      jumpTable.setDistance(branchForward, distance);

      String hexDistance = ConversionUtil.numToHex(distance);
      backPatch(branchForward, hexDistance);
    }
  }

  /**
   * Generates code for comparisons in if/while statements. 
   */
  Tree<dynamic> handleComparison(Tree<dynamic> currNode) {
    int len = currNode.children.length;
    Tree<dynamic> block = null;
    bool deode = false;

    // Simple if, ie. if true/false
    if (len == 2) {
      String boolean = currNode.children[0].data;

      // "if false" is dead code that we dont have to evaluate
      if (boolean == "true") {
        block = currNode.children[1];
      } else {
        return null;
      }
      // Complex if, ie. if (true == true)
    } else {
      String left = currNode.children[0].data;
      String right = currNode.children[2].data;
      block = currNode.children[3];

      // Check if value is an id
      if (staticTable.rowExists(right, scope)) {
        StaticTableRow row = staticTable.getRow(right, scope);

        if (row.type == StaticTable.TYPE_BOOLEAN) {
          String hex = ConversionUtil.booleanToHex(row.value);
          ldx_constant(hex);
        } else {
          ldx_memory(row.location);
        }
      } else {
        String type = ConversionUtil.determineType(right);
        if (type == StaticTable.TYPE_BOOLEAN) {
          String hex = ConversionUtil.booleanToHex(right);
          ldx_constant(hex);
        } else {
          ldx_constant(right);
        }
      }

      // Check if print value is an id
      if (staticTable.rowExists(left, scope)) {
        StaticTableRow row = staticTable.getRow(left, scope);
        // Load the memory location of the id into X register
        cpx(row.location);
      } else {
        String type = ConversionUtil.determineType(left);
        if (type == StaticTable.TYPE_BOOLEAN) {
          String hex = ConversionUtil.booleanToHex(right);
          cpx(hex);
        } else {
          cpx(left);
        }
      }
    }
    return block;
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

  void adc(String location) {
    log.info("Adding contents of ${location} to the accumulator");
    insertString("6D");
    insertString(location);
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

  int writeDataToHeap(String value) {
    // Assert event
    assert(value.length % 2 == 0);
    int index = findAvailableHeapMemory();

    if (index != null) {
      num byteLength = value.length / 2;
      int begin = index - byteLength.toInt() + 1;
      if (isAvailable(begin, index)) {
        setCode(begin, value);
        return begin;
      } else {
        ExceptionUtil.logAndThrow(new CompilerOutOfMemoryError("Not enough heap memory to write ${value}."), log);
      }
    } else {
      ExceptionUtil.logAndThrow(new CompilerOutOfMemoryError("Unable to find available heap memory."), log);
    }
    // Should never happen?
    return null;
  }

  int findAvailableHeapMemory() {
    for (var i = MAX_MEMORY - 1; i >= 0; i--) {
      if (this.code[i] == null) {
        return i;
      }
    }
    // No available memory found
    return null;
  }

  void resetZFlag() {
    // Load a temp value into memory
    int tempMemory = findAvailableHeapMemory();
    setCode(tempMemory, "02");
    String validAddress = ConversionUtil.numToHex(tempMemory);
    validAddress = ConversionUtil.toLittleEndian(validAddress, 4);

    // Load the x register and do a not equal comparison
    ldx_constant("1");
    cpx(validAddress);

    // Reset tempMemory address
    this.code[tempMemory] = null;
  }

  /**
   * Ensures that the range of memory is not already written to
   */
  bool isAvailable(int begin, int end) {
    for (var i = begin; i <= end; i++) {
      if (this.code[i] != null) {
        return false;
      }
    }
    // All desired addresses null
    return true;
  }

  void generateStaticVariables() {
    for (StaticTableRow row in this.staticTable.rows) {
      String currAddress = address.toRadixString(16);
      currAddress = ConversionUtil.toLittleEndian(currAddress, StaticTable.ADDRESS_LENGTH);

      // Update static table with real address
      row.setAddress(currAddress);

      // Backpatch code to use real address
      backPatch(row.location, currAddress);

      // Increment address
      address++;
    }
  }

  /**
   * Iterates over the code and replaces one value with another
   */
  void backPatch(String oldValue, String newValue) {

    // Assert that values are both even and the same length
    assert(oldValue.length % 2 == 0 && oldValue.length == newValue.length);

    num byteLength = oldValue.length / 2;

    log.info("Backpatching $oldValue with $newValue");
    for (var i = 0; i < this.code.length; i++) {
      String code = getCode(i, byteLength.toInt());
      if (code != null) {
        if (code == oldValue) {
          setCode(i, newValue);
        }
      }
    }
  }

  /**
   * Gets the code at the specified index with the specified length in bytes/indexes
   */
  String getCode(int index, int length) {
    String code = "";
    int end = index + length;
    if (end < this.code.length) {
      for (var i = index; i < end; i++) {
        if (this.code[i] != null) {
          code = code + this.code[i];
        } else {
          return null;
        }
      }
      return code;
    } else {
      return null;
    }
  }

  /**
   * Sets the code at the specified index 
   */
  void setCode(int index, String value) {

    assert(value.length % 2 == 0);

    double byteLength = value.length / 2;
    double end = index + byteLength;
    for (var i = index; i < end; i++) {
      String toAdd = value.substring(0, 2);
      this.code[i] = toAdd;
      value = value.substring(2, value.length);
    }
  }

  /**
   * Simply adds the string value to the code in byte formation.
   */
  void insertString(String value) {

    value = ConversionUtil.makeEven(value);

    for (var i = 0; i < value.length; i = i + 2) {
      String toAdd = value[i] + value[i + 1];
      code[address++] = toAdd;
    }
  }
}
