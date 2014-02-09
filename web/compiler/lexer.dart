/* lexer.dart  */
import 'package:poppy/trie.dart';
import 'token.dart';

class Lexer{
  String source;
  List<Token> tokens;
 
  Lexer(this.source){
    this.tokens = new List<Token>();
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
      
      // Keep track of line number
      int numLine = lines.indexOf(l);
      
      // Trim leading and trailing whitespace
      l = l.trim();
      
      // Get lexemes
      Iterable<Match> matches = splitPattern.allMatches(l);
      
      // Analyze each lexeme
      for (Match m in matches){
        String lexeme = m.group(0);
        
        if( lexeme == '\$'){
            print("End of program");
            break loop;
        }
        else if(numberPattern.hasMatch(lexeme)){
            Token token = new Token(TokenType.DIGIT, lexeme, numLine);
            this.tokens.add(token);
            print(lexeme);
            print(token.type);
        }
        else if(charPattern.hasMatch(lexeme)){
          Token token = new Token(TokenType.CHAR, lexeme, numLine);
          this.tokens.add(token);
          print(lexeme);
          print(token.type);
        }
        else if(stringPattern.hasMatch(lexeme)){
          // Not sure yet
        }
        else if(idPattern.hasMatch(lexeme)){
          Token token = new Token(TokenType.ID, lexeme, numLine);
          this.tokens.add(token);
          print(lexeme);
          print(token.type);
        } 
        else{
          print("Count not identify : " + lexeme);
        }
      }
    
    }
    
    Trie <String> reserved = new SimpleTrie();
    
    print(source);
  }
}

