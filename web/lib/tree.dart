library Tree;

class Tree<T> {

  dynamic data;
  Tree<dynamic> parent;
  List<Tree<dynamic>> children;
 
  Tree(this.data, this.parent) {
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
}
