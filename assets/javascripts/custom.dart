// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
