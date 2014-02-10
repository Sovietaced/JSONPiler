import 'dart:html';
import 'compiler/lexer.dart';
import 'package:logging/logging.dart';

void main() {
  
  // Init logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  
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