import 'package:polymer/builder.dart';

void main(List<String> args) {
  lint(entryPoints: ['index.html'], options: parseOptions(args));
}