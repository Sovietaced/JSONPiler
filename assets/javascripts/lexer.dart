/* lexer.dart  */
import 'dart:html';

    void lex(MouseEvent event)
    {   
      var source = (querySelector("#input-code") as TextAreaElement).value;
      // Trim the leading and trailing spaces.
      source = source.trim();
      // Strip all whitespace
      source = source.replaceAll(new RegExp(r'\s+'), '\n');
      print(source);
    }

