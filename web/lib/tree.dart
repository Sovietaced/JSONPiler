library Tree;

import '../compiler/symbol.dart';
import '../compiler/token.dart';

class Tree<T> {

  dynamic data;
  String line;
  Tree<dynamic> parent;
  List<Tree<dynamic>> children;
 
  Tree(this.data, this.parent, this.line) {
    this.children = new List<Tree<dynamic>>();
  }
  
  void addChild(Tree<dynamic> child) {
    this.children.add(child);
  }
  
  void addChildren(List<Tree<dynamic>> children) {
    this.children.addAll(children);
  }
  
  String toString() {
    return this.data.toString();
  }
  /**
   * Recursive data dump for debugging
   */
  void dump() {
    print("Dumping tree ${this} with parent ${this.parent}");
    for(Tree<dynamic> child in this.children){
      child.dump();
    }
  }
  
  String syntrify() {
    String syntree = " [";
    
    if(this.data is NonTerminal){
      NonTerminal nt = this.data as NonTerminal;
      syntree = syntree + nt.value;
    }else if(this.data is TokenType){
      TokenType tt = this.data as TokenType;
      syntree = syntree + tt.value;
    }
    else{
      syntree = syntree + this.toString();
    }
    
    for(Tree<dynamic> child in this.children){
      syntree = syntree + child.syntrify();
    }
    
    syntree = syntree + "] ";
    return syntree;
  }
}
