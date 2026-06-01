import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalRemoved = 0;

  for (final file in files) {
    var content = file.readAsStringSync();
    final lines = content.split('\n');
    final newLines = <String>[];
    
    bool changed = false;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('//')) {
        changed = true;
        totalRemoved++;
        continue;
      }
      
      int commentIdx = line.indexOf('//');
      if (commentIdx != -1) {
        if (!line.contains('http://') && !line.contains('https://') && !line.contains('://')) {
          line = line.substring(0, commentIdx).trimRight();
          changed = true;
          totalRemoved++;
        }
      }
      newLines.add(line);
    }
    
    if (changed) {
      // Clean up consecutive empty lines
      final finalLines = <String>[];
      for (int i = 0; i < newLines.length; i++) {
        if (newLines[i].trim().isEmpty) {
          if (finalLines.isEmpty || finalLines.last.trim().isEmpty) {
            continue;
          }
        }
        finalLines.add(newLines[i]);
      }
      file.writeAsStringSync(finalLines.join('\n'));
    }
  }
  
  print('Removed $totalRemoved comments across the project.');
}
