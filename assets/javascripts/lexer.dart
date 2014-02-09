/* lexer.dart  */
import 'package:poppy/trie.dart';

class Lexer{
  String source;
  List<Token> tokens;
 
  Lexer(this.source){
    this.tokens = new List<String>();
  }
  
  analyze() {
    
    // Patterns
    RegExp splitPattern = new RegExp(r'([a-z]+)|(\d+)|("[^"]*")|(==)|(\S)');
    RegExp numberPattern = new RegExp(r'\d+');
    RegExp charPattern = new RegExp(r'[a-z]');
    RegExp stringPattern = new RegExp(r'"[^"]*"');
    RegExp idPattern = new RegExp(r'[a-z]+');
    
    // Split source by new line
    var lines = this.source.split("\n");
    
    loop:
    for(String l in lines){
      
      // Trim leading and trailing whitespace
      l = l.trim();
      // Get lexemes
      Iterable<Match> matches = splitPattern.allMatches(l);
      // Analyze each lexeme
      for (Match m in matches){
        String lexeme = m.group(0);
        
        switch(lexeme){
          case '\$':
            print("End of program");
            break loop;
          default :
            print(lexeme);
        }
        
      }
    
    }
    
    Trie <String> reserved = new SimpleTrie();
    
    print(source);
  }
}

