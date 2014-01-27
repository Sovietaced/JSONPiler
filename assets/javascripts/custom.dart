import 'dart:html';

void main() {
  // Hide on load
  querySelector("#output").hidden = true;
  
  // Listener
  querySelector("#compile")
    ..onClick.listen(unhide);
}

void unhide(MouseEvent event) {
  querySelector("#output").hidden = false;
}