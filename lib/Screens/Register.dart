import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:dio/dio.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String baseurl = "https://4ef1-110-138-88-118.ngrok-free.app/vigenesia";

  Future postRegister(
      String nama, String profesi, String email, String password) async {
    var dio = Dio();
    dynamic data = {
      "nama": nama,
      "profesi": profesi,
      "email": email,
      "password": password
    };

    try {
      final response = await dio.post(
        "$baseurl/api/registrasi",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Registrasi berhasil: ${response.data}");
        return response.data;
      } else {
        print("Registrasi gagal dengan status: ${response.statusCode}");
        return null;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        // Server returned a response with an error code
        print("Server Error: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        // No response from server (e.g., no internet or timeout)
        print("Failed To Load: ${e.message}");
      }
      return null;
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController profesiController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.3,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register Your Account",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 50),
                  FormBuilderTextField(
                    name: "name",
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      border: OutlineInputBorder(),
                      labelText: "Nama",
                    ),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    name: "profesi",
                    controller: profesiController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      border: OutlineInputBorder(),
                      labelText: "Profesi",
                    ),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    name: "email",
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      border: OutlineInputBorder(),
                      labelText: "Email",
                    ),
                  ),
                  SizedBox(height: 20),
                  FormBuilderTextField(
                    obscureText: true,
                    name: "password",
                    controller: passwordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      border: OutlineInputBorder(),
                      labelText: "Password",
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            profesiController.text.isNotEmpty &&
                            emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          var result = await postRegister(
                            nameController.text,
                            profesiController.text,
                            emailController.text,
                            passwordController.text,
                          );

                          if (result != null) {
                            Navigator.pop(context);
                            Flushbar(
                              message: "Berhasil Registrasi",
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.greenAccent,
                              flushbarPosition: FlushbarPosition.TOP,
                            ).show(context);
                          } else {
                            Flushbar(
                              message:
                                  "Registrasi gagal. Cek kembali inputan Anda.",
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.redAccent,
                              flushbarPosition: FlushbarPosition.TOP,
                            ).show(context);
                          }
                        } else {
                          Flushbar(
                            message: "Lengkapi semua field sebelum mendaftar.",
                            duration: Duration(seconds: 5),
                            backgroundColor: Colors.orangeAccent,
                            flushbarPosition: FlushbarPosition.TOP,
                          ).show(context);
                        }
                      },
                      child: Text("Daftar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
