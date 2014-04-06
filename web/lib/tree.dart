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
}
