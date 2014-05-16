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
  querySelector("#output").hidden = false;
}

void compile(MouseEvent event) {
  // Clear out textareas
  (querySelector("#symbol-table") as TextAreaElement).text = '';
  (querySelector("#log-all") as TextAreaElement).text = '';
  (querySelector("#badge-all") as SpanElement).text = '0';
  (querySelector("#log-info") as TextAreaElement).text = '';
  (querySelector("#badge-info") as SpanElement).text = '0';
  (querySelector("#log-warning") as TextAreaElement).text = '';
  (querySelector("#badge-warning") as SpanElement).text = '0';
  (querySelector("#log-severe") as TextAreaElement).text = '';
  (querySelector("#badge-severe") as SpanElement).text = '0';

  var source = (querySelector("#input-code") as TextAreaElement).value;
  Compiler compiler = new Compiler(source);
  compiler.run();
  
}