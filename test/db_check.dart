import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test farmacia insert with usuario_id', () async {
    final headers = {
      'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaHl5emxhbmp1Y3p1ZGRzenltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NjIwNjksImV4cCI6MjA5MzAzODA2OX0.QaXBaYH-UJyx_ZBpOLPdgQkKOCa9Imz4Rq6k5KQGK6I',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxaHl5emxhbmp1Y3p1ZGRzenltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NjIwNjksImV4cCI6MjA5MzAzODA2OX0.QaXBaYH-UJyx_ZBpOLPdgQkKOCa9Imz4Rq6k5KQGK6I',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal'
    };

    final url = Uri.parse('https://qqhyyzlanjuczuddszym.supabase.co/rest/v1/farmacia');
    final body = jsonEncode({
      'usuario_id': '12345678-1234-1234-1234-123456789012',
      'nombre': 'Test Farmacia',
      'direccion': 'Test Dir'
    });
    
    final res = await http.post(url, headers: headers, body: body);
    print("Post status: ${res.statusCode}");
    print("Post body: ${res.body}");
  });
}
