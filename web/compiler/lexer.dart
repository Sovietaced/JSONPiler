/* lexer.dart  */
import 'token.dart';
import 'package:logging/logging.dart';

class Lexer{
  
  // Logging
  final Logger log = new Logger('Lexer');
  
  String source;
  List<Token> tokens;
                  
 
  Lexer(this.source){
    this.tokens = new List<Token>();
  }
  
  // Run lexical analysis against Lexer instance source code
  analyze() {
    
    // Patterns
    RegExp splitPattern = new RegExp(r'([a-z]+)|(\d+)|("[^"]*")|(==)|(\S)');
    RegExp numberPattern = new RegExp(r'\d+');
    RegExp charPattern = new RegExp(r'[a-z]');
    RegExp stringPattern = new RegExp(r'[^"]*"');
    RegExp idPattern = new RegExp(r'[a-z]+');
    
    // Split source by new line
    var lines = this.source.split("\n");
    
    // Named loop so that we can break out of it from inner loop
    loop:
    for(String l in lines){
      
      // Keep track of line number (Increment by 1 for humans)
      int numLine = lines.indexOf(l) + 1;
      
      // Trim leading and trailing whitespace
      l = l.trim();
      
      // Get lexemes
      Iterable<Match> matches = splitPattern.allMatches(l);
      
      // Analyze each lexeme
      for (Match m in matches){
        // Extract lexeme from Regex match 
        String lexeme = m.group(0);
        
        // END
        if( lexeme == '\$'){
            this.tokens.add(new Token(TokenType.END, "\$", numLine));
            break loop;
        }
        
        // STRINGS
        else if(stringPattern.hasMatch(lexeme)){
          
          // Begin quote
          this.tokens.add(new Token(TokenType.QUOTE, "\"", numLine));
          
          String str_lexeme = lexeme.replaceAll("\"", "");
          
          // String characters
          for(var code in str_lexeme.codeUnits){
            String char = new String.fromCharCode(code);
            this.tokens.add(new Token(TokenType.CHAR, char, numLine));
          }
          
          // Trailing quote
          this.tokens.add(new Token(TokenType.QUOTE, "\"", numLine));
        }
        
        // NUMBERS
        else if(numberPattern.hasMatch(lexeme)){
            this.tokens.add(new Token(TokenType.DIGIT, lexeme, numLine));
        }
        
        // IDs
        else if(idPattern.hasMatch(lexeme)){
          if(TokenType.RESERVED.containsKey(lexeme)){
            this.tokens.add(new Token(TokenType.RESERVED[lexeme], lexeme, numLine));
          }
          else {
            this.tokens.add(new Token(TokenType.ID, lexeme, numLine));
          }
        } 
        
        // SYMBOLS/OTHERS
        else{
          if(TokenType.SYMBOLS.containsKey(lexeme)){
            this.tokens.add(new Token(TokenType.SYMBOLS[lexeme], lexeme, numLine));
          }
          else{
          log.warning("Count not identify : " + lexeme);
          }
        }
      }
      // If we end up here we have not found an ending symbol
      log.warning("Code missing \$ symbol! Inserting for you.");
      this.tokens.add(new Token(TokenType.END, "\$", lines.length + 1));
    }
    
    // DUMP
    for(Token t in this.tokens){
      print(t.toString());
    }
    
  }
  
}

