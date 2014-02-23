class SyntaxError implements Exception {
  String message = "";
  SyntaxError(this.message);
  
  String toString() => "Syntax Error: $message";
}

class TypeError implements Exception {
  String message = "";
  TypeError(this.message);
  
  String toString() => "Type Error: $message";
}