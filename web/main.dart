import 'dart:html';
import 'compiler/compiler.dart';
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
  //querySelector("#output").hidden = false;
}

void compile(MouseEvent event) {
  // Clear out textareas
  (querySelector("#symbol-table") as TextAreaElement).text = '';
  (querySelector("#log") as TextAreaElement).text = '';
  

  // Unlock textareas
  (querySelector("#symbol-table") as TextAreaElement).attributes.remove("readonly");
  (querySelector("#log") as TextAreaElement).attributes.remove("readonly");
  
  var source = (querySelector("#input-code") as TextAreaElement).value;
  Compiler compiler = new Compiler(source);
  compiler.run();
  
  // Lock up textareas
  (querySelector("#symbol-table") as TextAreaElement).setAttribute("readonly", '');
  (querySelector("#log") as TextAreaElement).setAttribute("readonly", '');
  
}