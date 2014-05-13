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

  void generateCode() {
    log.info("Code Generation starting...");
    // Recursively parse starting block
    parseBlock(this.ast);
    // Break
    brk();
    
    generateStaticVariables();

    setNullToZero();
    
    print(this.code.join(""));
    staticTable.dump();
    log.info("Code Generation finished...");
  }
  
  void setNullToZero() {
    for(var i=0; i < MAX_MEMORY; i++) {
      if(this.code[i] == null) {
        this.code[i] = "00";
      }
    }
  }

  void parseBlock(Tree<dynamic> currNode) {
    log.info("Parsing a block");
    
    // Increment scope
    scope++;
    
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
    
    // Decriment scope
    scope--;
  }

  void generateVariableDeclaration(Tree<dynamic> currNode) {
    log.info("Generating code for a variable declaration");
    String type = currNode.children[0].data;
    String id = currNode.children[1].data;
    
    if(type == StaticTable.TYPE_INT) {
      // Make entry in static table
      String location = staticTable.addRow(id, StaticTable.TYPE_INT, scope);
  
      // Load accumulator with 0
      lda_constant("0");
      sta(location);
    } else if (type == StaticTable.TYPE_STRING) {
      // Make entry in static table
      staticTable.addRow(id, StaticTable.TYPE_STRING, scope);
    } // FIXME: HANDLE BOOLEANS

  }

  /**
   * Generates code for an assignment statement.
   */
  void generateAssignmentStatement(Tree<dynamic> currNode) {
    log.info("Generating code for an assignment statement");
    String id = currNode.children[0].data;
    StaticTableRow leftRow = staticTable.getRow(id, scope);

    //FIXME: handle advanced statements here
    String right = currNode.children[1].data;

    // Check if right hand side of assignment is an id
    if (staticTable.rowExists(right, scope)) {
      //FIXME: handle different possibilities of scope
      StaticTableRow rightRow = staticTable.getRow(right, scope);
      lda_memory(rightRow.location);
      sta(leftRow.location);
    } else {
      print(leftRow.type);
      if(leftRow.type == StaticTable.TYPE_INT) {
        // Load accumulator with rightside of assignment
        lda_constant(right);
        sta(leftRow.location);
      } else if(leftRow.type == StaticTable.TYPE_STRING) {
        String hexString = stringToHex(right);
        
        // Write the hexString to heap, get address back
        int index = writeDataToHeap(hexString);
        print("index of heap is " + index.toString());
        // Convert address to hex string and store static pointer
        String hexIndex = numToHex(index);
        print("index of heap is " + hexIndex);
        lda_constant(hexIndex);
        sta(leftRow.location);
        
      } else if(leftRow.type == StaticTable.TYPE_BOOLEAN) {
        //FIXME: handle booleans
      }
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
    if (staticTable.rowExists(left, scope)) {
      StaticTableRow row = staticTable.getRow(left, scope);
      // Load the memory location of the id into Y register
      ldx_memory(row.location);
    } else {
      //FIXME: other things besides integers could be here, like booleans
      ldx_constant(left);
    }

    // Check if print value is an id
    if (staticTable.rowExists(right, scope)) {
      StaticTableRow row = staticTable.getRow(right, scope);
      cpx(row.location);
    } else {
      //FIXME: other things besides integers could be here, like booleans
      cpx(right);
    }

    // Make new entry in the jump table
    String location = jumpTable.addRow();
    bne(location);

    int preBranch = address;
    parseBlock(block);
    int postBranch = address;

    // Calculate jump distance
    int distance = (postBranch - preBranch);
    jumpTable.setDistance(location, distance);

    String hexDistance = numToHex(distance);
    backPatch(location, hexDistance);
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
  
  int writeDataToHeap(String value) {
    // Assert event
    assert(value.length % 2 == 0);
    print("value " + value);
    print(this.code);
    int index = findAvailableHeapMemory();
    
    if(index != null) {
      num byteLength = value.length / 2;
      int begin = index - byteLength.toInt()+1;
      if(isAvailable(begin, index)) {
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
  
  num findAvailableHeapMemory() {
    for(var i = MAX_MEMORY-1; i >= 0; i++) {
      if(this.code[i] == null) {
        return i;
      }
    }
    // No available memory found
    return null;
  }
  
  /**
   * Ensures that the range of memory is not already written to
   */
  bool isAvailable(int begin, int end) {
    for(var i=begin; i <= end; i++) {
      if(this.code[i] != null) {
        return false;
      }
    }
    // All desired addresses null
    return true;
  }

  void generateStaticVariables() {
    for (StaticTableRow row in this.staticTable.rows) {
      if(row.type == StaticTable.TYPE_INT) {
        String currAddress = address.toRadixString(16);
        currAddress = toLittleEndian(currAddress, StaticTable.ADDRESS_LENGTH);
        
        // Update static table with real address
        row.setAddress(currAddress);
        
        // Backpatch code to use real address
        backPatch(row.location, currAddress);
        
        // Increment address
        address++;
      } else if(row.type == StaticTable.TYPE_STRING) {
        print("meow");
      }
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
      if(code != null) {
        if(code == oldValue) {
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
    if(end < this.code.length) {
      for(var i = index; i < end; i++) { 
        if(this.code[i] != null) {
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
    for(var i=index; i < end; i++) {
      String toAdd = value.substring(0,2);
      this.code[i] = toAdd;
      value = value.substring(2, value.length);
    }
  }

  /**
   * Generates a littleEndian version of the string by adding leading zeroes
   */
  String toLittleEndian(String value, int desiredLength) {
    assert(value.length <= 2); // to remind me to enhance this if needed
    value = makeEven(value);

    while (value.length < desiredLength) {
      value = value + "00";
    }
    
    print("NEW EVEN VALUE BRO " + value.toUpperCase());
    return value.toUpperCase();
  }

  String makeEven(String value) {
    // Make string even
    if (value.length % 2 != 0) {
      if (value.length == 1) {
        value = "0" + value;
      } else {
        value = value.substring(0, value.length - 2) + "0" + value[value.length - 1];
      }
    }
    return value;
  }

  String numToHex(int value) {
    String number = value.toRadixString(16).toUpperCase();
    return makeEven(number);
  }
  
  /**
   * Turns a plain old string into a null terminated hex string ready for code.
   * Iterates over the character codes and encodes the integer values into hex.
   */
  String stringToHex(String value) {
    String hexString = "";
    // Strip quotes
    value = value.replaceAll("\"", "");
    
    for(int i in value.codeUnits) {
      hexString = hexString + numToHex(i);
    }
    
    // Null terminate
    hexString = hexString + "00";
    
    return hexString;
  }
  
  void addNumToHex(int value) {
    //
  }

  /**
   * Simply adds the string value to the code in byte formation.
   */
  void insertString(String value) {

    value = makeEven(value);

    for (var i = 0; i < value.length; i = i + 2) {
      String toAdd = value[i] + value[i + 1];
      code[address++] = toAdd;
    }
  }
}
