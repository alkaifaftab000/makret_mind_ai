import 'dart:convert';
import 'dart:io';

void main() {
  final content = File('/Users/avinash/imc_frontend/makret_mind_ai/analyze_output.txt').readAsStringSync();
  print(content.length);
}
