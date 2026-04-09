import 'dart:io';

void main() {
  final files = ['lib/screens/home_screen.dart', 'lib/screens/parcel_details_screen.dart', 'lib/screens/add_parcel_screen.dart'];
  final exp = RegExp(r'\.withValues\(alpha:\s*([\d.]+)\)');
  for (final path in files) {
    final file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      content = content.replaceAllMapped(exp, (m) => '.withOpacity(${m[1]})');
      file.writeAsStringSync(content);
    }
  }
}
