import 'dart:html';
import 'compiler/lexer.dart';

void main() {
  // Hide on load
  querySelector("#output").hidden = true;
  
  // Listener
  querySelector("#compile")
    ..onClick.listen(unhide)
    ..onClick.listen(compile);
}

void unhide(MouseEvent event) {
  querySelector("#output").hidden = false;
}

void compile(MouseEvent event) {
  var source = (querySelector("#input-code") as TextAreaElement).value;
  Lexer lexer = new Lexer(source);
  lexer.analyze();
}