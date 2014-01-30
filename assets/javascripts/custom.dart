import 'dart:html';
import 'lexer.dart';

void main() {
  // Hide on load
  querySelector("#output").hidden = true;
  
  // Listener
  querySelector("#compile")
    ..onClick.listen(unhide)
    ..onClick.listen(lex);
}

void unhide(MouseEvent event) {
  querySelector("#output").hidden = false;
}