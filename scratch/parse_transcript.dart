import 'dart:convert';
import 'dart:io';

void main() {
  try {
    final file = File(r'C:\Users\swapna.boyapati\.gemini\antigravity-ide\brain\e6068cfa-b6b5-4ee2-b7c9-1f5c3bb57228\.system_generated\logs\transcript.jsonl');
    if (!file.existsSync()) {
      print('File not found');
      return;
    }
    final firstLine = file.readAsLinesSync().first;
    final parsed = jsonDecode(firstLine);
    final content = parsed['content'] as String;
    
    // Search for API definitions
    final index = content.indexOf('Submitted Stocks API');
    if (index != -1) {
      print(content.substring(index, (index + 2000).clamp(0, content.length)));
    } else {
      print('Submitted Stocks API keyword not found in transcript. Searching for "records" instead:');
      final index2 = content.indexOf('"records"');
      if (index2 != -1) {
        print(content.substring((index2 - 500).clamp(0, content.length), (index2 + 1500).clamp(0, content.length)));
      } else {
        print('Neither found');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
