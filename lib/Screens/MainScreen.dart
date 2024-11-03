import 'dart:convert';
import '/../Models/Motivasi_Model.dart';
import '/../Screens/EditPage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'Login.dart';
import 'package:another_flushbar/flushbar.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  const MainScreens({Key? key, this.nama}) : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl =
      "https://4ef1-110-138-88-118.ngrok-free.app/vigenesia"; // Gunakan IP lokal atau alamat yang sesuai
  var dio = Dio();
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": isi,
    };

    try {
      Response response =
          await dio.post("$baseurl/api/dev/POSTmotivasi/", data: body);

      if (response.statusCode == 200) {
        print("Respon -> ${response.data}");
        return response.data;
      } else {
        throw Exception("Gagal mengirim motivasi");
      }
    } catch (e) {
      print("Error -> $e");
      return null;
    }
  }

  List<MotivasiModel> listproduk = [];

  Future<List<MotivasiModel>> getData() async {
    try {
      var response = await dio.get('$baseurl/api/Get_motivasi/');

      if (response.statusCode == 200) {
        var getUsersData = response.data as List;
        var listUsers =
            getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
        return listUsers;
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print("Error -> $e");
      return [];
    }
  }

  Future<dynamic> deletePost(String id) async {
    try {
      var response = await dio.delete('$baseurl/api/dev/DELETEmotivasi/$id');

      if (response.statusCode == 200) {
        print("Berhasil delete: ${response.data}");
        return response.data;
      } else {
        throw Exception("Gagal menghapus motivasi");
      }
    } catch (e) {
      print("Error -> $e");
      return null;
    }
  }

  Future<void> _getData() async {
    setState(() {
      getData();
    });
  }

  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hallo ${widget.nama}",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                FormBuilderTextField(
                  controller: isiController,
                  name: "isi_motivasi",
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      var result =
                          await sendMotivasi(isiController.text.toString());
                      if (result != null) {
                        Flushbar(
                          message: "Berhasil Submit",
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.greenAccent,
                          flushbarPosition: FlushbarPosition.TOP,
                        ).show(context);
                      }
                      _getData();
                    },
                    child: Text("Submit"),
                  ),
                ),
                SizedBox(height: 40),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _getData,
                ),
                FutureBuilder<List<MotivasiModel>>(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No Data");
                    } else {
                      return Column(
                        children: snapshot.data!.map((item) {
                          return Container(
                            width: double.infinity,
                            child: ListTile(
                              title: Text(item.isiMotivasi.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.settings),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(
                                            id: item.id,
                                            isi_motivasi: item.isiMotivasi,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await deletePost(item.id!);
                                      Flushbar(
                                        message: "Berhasil Delete",
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.redAccent,
                                        flushbarPosition: FlushbarPosition.TOP,
                                      ).show(context);
                                      _getData();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
