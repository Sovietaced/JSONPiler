/* lexer.dart  */
import 'dart:html';
import 'package:poppy/trie.dart';

class Lexer{
  String source;
  List<Token> tokens;
 
  Lexer(this.source){
    this.tokens = new List<String>();
  }
  
  analyze() {
    
    // Patterns
    var _numberPattern = '/\d+/';
    var _charPattern = '/[a-z]/';
    var _stringPattern = '/"[^"]*"/';
    var _idPattern = '/[a-z]+/';
    
    // Trim the leading and trailing spaces.
    var source = this.source.trim();
    // Strip all whitespace
    //source = source.replaceAll(new RegExp(r'\s+'), '\n');
    
    // Split source by whitespace
    source = source.split(new RegExp(r'\s+'));
    
    
    Trie <String> reserved = new SimpleTrie();
    
    print(source);
  }
}

