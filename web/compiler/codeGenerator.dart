/* codeGenerator.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * */

library codeGenerator;

import '../util/logger_util.dart';
import 'package:logging/logging.dart';
import '../lib/tree.dart'; 
import 'token.dart';
import 'staticTable.dart';
import 'exceptions.dart';
import '../util/exception_util.dart';


class CodeGenerator{
  
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
    code.add("8d");
    address++;
    insertString(location);
  }
  
  void addNumToHex(int value) {
    String number = value.toRadixString(16);
    // chop hex string into twos
    //insert and increment accordingly
  }
  
  void insertString(String value) {
    
  }
  
}