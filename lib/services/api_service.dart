import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  // JSONPlaceholder is a mock API, so "login" just checks that the user exists.
  Future<User> fetchUser(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw ApiException('User $id was not found.');
      }
      if (response.statusCode != 200) {
        throw ApiException('Server error (${response.statusCode}).');
      }
      return User.fromJson(jsonDecode(response.body));
    } on SocketException {
      throw ApiException('No internet connection.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException('Network error. Please try again.');
    }
  }
}
