/* lexer.dart  */
import 'dart:html';
import 'package:poppy/trie.dart';

    void lex(MouseEvent event)
    {   
      var source = (querySelector("#input-code") as TextAreaElement).value;
      // Trim the leading and trailing spaces.
      source = source.trim();
      // Strip all whitespace
      //source = source.replaceAll(new RegExp(r'\s+'), '\n');
      
      // Split source by whitespace
      source = source.split(new RegExp(r'\s+'));
      
      Trie <String> reserved = new SimpleTrie();
      
      print(source);
    }

