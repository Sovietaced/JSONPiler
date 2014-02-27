/* lexer.dart
 * Jason Parraga <Sovietaced@gmail.com>  
 * 
 * Static compiler lexer class. Performs lexical analysis on a source string
 * */

library Lexer;

import '../util/logger_util.dart';
import 'package:logging/logging.dart';
import 'token.dart';


class Lexer{
  
  // Logging
  static Logger log = LoggerUtil.createLogger('Lexer');
  
  // Run lexical analysis against Lexer instance source code
  static analyze(String source) {
    
    // Keeps track if terminated
    bool terminated = false;
    
    // Tokens
    List<Token> tokens = new List<Token>();
    
    // Patterns
    RegExp splitPattern = new RegExp(r'([a-z]+)|(\d+)|("[^"]*")|(!=)|(==)|(\S)');
    RegExp numberPattern = new RegExp(r'\d+');
    RegExp charPattern = new RegExp(r'[a-z]');
    RegExp stringPattern = new RegExp(r'[^"]*"');
    RegExp idPattern = new RegExp(r'[a-z]+');

    
    // Split source by new line
    var lines = source.split("\n");
    
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
            tokens.add(new Token(TokenType.END, "\$", numLine));
            terminated = true;
            break loop;
        }
        
        // STRINGS
        else if(stringPattern.hasMatch(lexeme)){
          
          // Begin quote
          tokens.add(new Token(TokenType.QUOTE, "\"", numLine));
          
          String str_lexeme = lexeme.replaceAll("\"", "");
          
          // String characters
          for(var code in str_lexeme.codeUnits){
            String char = new String.fromCharCode(code);
            if(char == ' '){
              tokens.add(new Token(TokenType.SPACE, char, numLine));
            }
            else{
              tokens.add(new Token(TokenType.CHAR, char, numLine));
            }
          }
          
          // Trailing quote
          tokens.add(new Token(TokenType.QUOTE, "\"", numLine));
        }
        
        // NUMBERS
        else if(numberPattern.hasMatch(lexeme)){
            tokens.add(new Token(TokenType.DIGIT, lexeme, numLine));
        }
        
        // RESERVED WORDS / IDs
        else if(idPattern.hasMatch(lexeme)){
          if(TokenType.RESERVED.containsKey(lexeme)){
            tokens.add(new Token(TokenType.RESERVED[lexeme], lexeme, numLine));
          }
          else {
            tokens.add(new Token(TokenType.ID, lexeme, numLine));
          }
        } 
        
        // SYMBOLS/OTHERS
        else{
          if(TokenType.SYMBOLS.containsKey(lexeme)){
            tokens.add(new Token(TokenType.SYMBOLS[lexeme], lexeme, numLine));
          }
          else{
          log.warning("Count not identify : " + lexeme );
          }
        }
      }
    }
    
    if(!terminated){
      log.warning("Code missing \$ symbol! Inserting for you.");
      tokens.add(new Token(TokenType.END, "\$", lines.length + 1));
    }
    
    // DUMP
    for(Token t in tokens){
      log.info(t.toString());
    }
    return tokens;
  } 
}