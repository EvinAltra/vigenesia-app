// lib/services/api_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Tambahkan impor ini untuk IOHttpClientAdapter

class ApiService {
  final String baseUrl = "https://9cdb-103-175-225-47.ngrok-free.app/vigenesia/api";

  Future<dynamic> postRegister(String nama, String profesi, String email, String password) async {
    var dio = Dio();

    // Menggunakan IOHttpClientAdapter untuk melewati verifikasi SSL
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dynamic data = {
      "nama": nama,
      "profesi": profesi,
      "email": email,
      "password": password
    };

    try {
      final response = await dio.post(
        "$baseUrl/register",
        data: data,
        options: Options(headers: {'Content-type': 'application/json'}),
      );

      print("Respon -> ${response.data} + ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("Registration failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Failed To Load $e");
      return null;
    }
  }
}
