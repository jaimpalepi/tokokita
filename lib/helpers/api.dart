import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tokokita/helpers/user_info.dart';
import 'app_exception.dart';

class Api {
  Future<dynamic> post(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      print("=== API POST ===");
      print("URL: $url");
      print("Data: $data");
      print("Token: $token");

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(data),
        headers: token != null
            ? {
                HttpHeaders.authorizationHeader: "Bearer $token",
                HttpHeaders.contentTypeHeader: "application/json",
                'auth-key': token, // Tambahkan auth-key header
              }
            : {HttpHeaders.contentTypeHeader: "application/json"},
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> get(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      print("=== API GET ===");
      print("URL: $url");
      print("Token: $token");

      final response = await http.get(
        Uri.parse(url),
        headers: token != null
            ? {
                HttpHeaders.authorizationHeader: "Bearer $token",
                'auth-key': token,
              }
            : {},
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(dynamic url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      print("=== API PUT ===");
      print("URL: $url");
      print("Data: $data");
      print("Token: $token");

      final response = await http.put(
        Uri.parse(url),
        body: data,
        headers: token != null
            ? {
                HttpHeaders.authorizationHeader: "Bearer $token",
                HttpHeaders.contentTypeHeader: "application/json",
                'auth-key': token,
              }
            : {HttpHeaders.contentTypeHeader: "application/json"},
      );

      print("Response Status: ${response.statusCode}");

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> delete(dynamic url) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      print("=== API DELETE ===");
      print("URL: $url");
      print("Token: $token");

      final response = await http.delete(
        Uri.parse(url),
        headers: token != null
            ? {
                HttpHeaders.authorizationHeader: "Bearer $token",
                'auth-key': token,
              }
            : {},
      );

      print("Response Status: ${response.statusCode}");

      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 422:
        throw InvalidInputException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}',
        );
    }
  }
}