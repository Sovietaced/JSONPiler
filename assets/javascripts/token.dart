
class Token {
  String name;
  String kind;
  var value;
  num the_num;
  num position;

  Token(this.name, this.kind, this.value, this.the_num, this.position);
}