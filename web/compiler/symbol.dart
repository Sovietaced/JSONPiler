/* symbol.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Compiler symbol class
 * */

library Symbol;

import 'dart:html';

class CompilerSymbol{
  
  String id;
  num scope;
  num line;
  String type;
  
  CompilerSymbol(this.id, this.scope, this.line, this.type){
    querySelector("#symbol-table").appendText(this.toString());
  }
  
  String toString(){
    return "Symbol: name=${this.id} scope=${this.scope} line=${this.line} type=${this.type} \n";
  }
}