class SyntaxError implements Exception {
  String message = "";
  SyntaxError(this.message);
  
  String toString() => "Syntax Error: $message";
}