/* exceptions.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Here lie exceptions thrown by my compiler
 * */

class CompilerSyntaxError implements Exception {
  String message = "";
  CompilerSyntaxError(this.message);
  
  String toString() => "Syntax Error: $message";
}

class CompilerTypeError implements Exception {
  String message = "";
  CompilerTypeError(this.message);
  
  String toString() => "Type Error: $message";
}

class CompilerOutOfMemoryError implements Exception {
  String message = "";
  CompilerOutOfMemoryError(this.message);
  
  String toString() => "Out of Memory Error: $message";
}