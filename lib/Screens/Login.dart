import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'MainScreen.dart';
import 'Register.dart';
import 'package:another_flushbar/flushbar.dart';
import '/../Models/Login_Model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? nama;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<LoginModels?> postLogin(String email, String password) async {
    var dio = Dio();
    String baseurl = "https://4ef1-110-138-88-118.ngrok-free.app/vigenesia";

    Map<String, dynamic> data = {"email": email, "password": password};

    try {
      final response = await dio.post("$baseurl/api/login/",
          data: data,
          options: Options(headers: {'Content-type': 'application/json'}));

      print(
          "Response -> ${response.data} + Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Periksa format respons sebelum diubah menjadi model
        if (response.data is Map<String, dynamic>) {
          return LoginModels.fromJson(response.data);
        } else {
          print("Invalid response format");
          return null;
        }
      } else {
        print("Login failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Failed to load: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Security System - Login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 50),
                Center(
                  child: Form(
                    key: _fbKey,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
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
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t Have an Account? ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextSpan(
                                  text: 'Sign Up',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Register(),
                                        ),
                                      );
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              onPressed: () async {
                                await postLogin(emailController.text,
                                        passwordController.text)
                                    .then((value) {
                                  if (value != null) {
                                    setState(() {
                                      nama = value.data?.nama;
                                    });
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            MainScreens(nama: nama!),
                                      ),
                                    );
                                  } else {
                                    Flushbar(
                                      message: "Check Your Email / Password",
                                      duration: Duration(seconds: 5),
                                      backgroundColor: Colors.redAccent,
                                      flushbarPosition: FlushbarPosition.TOP,
                                    ).show(context);
                                  }
                                });
                              },
                              child: Text("Sign In"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
