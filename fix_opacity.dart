import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final exp = RegExp(r'\.withOpacity\(\s*([\d.]+)\s*\)');
  int changedCount = 0;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      if (content.contains('.withOpacity(')) {
        content = content.replaceAllMapped(exp, (m) => '.withValues(alpha: ${m[1]})');
        entity.writeAsStringSync(content);
        changedCount++;
      }
    }
  }
  print('Updated $changedCount files.');
}
