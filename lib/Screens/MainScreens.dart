import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:org/Constant/const.dart';
import 'Login.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:org/Models/Motivasi_Model.dart';
import 'package:org/Screens/EditPage.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'EditProfile.dart';

class MainScreens extends StatefulWidget {
  final String? nama;
  final String? iduser;

  const MainScreens({Key? key, this.nama, this.iduser}) : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = url;
  late Dio dio;
  List<MotivasiModel> ass = [];
  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dio = Dio(BaseOptions(
      baseUrl: baseurl,
      connectTimeout: null, // No timeout
      receiveTimeout: null, // No timeout
    ));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    _fetchMotivasiList();
  }

  Future<List<MotivasiModel>> getData() async {
    try {
      final response = await dio.get(
        'http://10.0.2.2/vigenesia/api/dev/Get_motivasi',
        queryParameters: {
          'iduser': widget.iduser,
        },
      );

      if (response.statusCode == 200) {
        var getUsersData = response.data as List;
        return getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      } else {
        throw Exception('Server returned error code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
      throw Exception("Failed to fetch data");
    }
  }

  Future<void> sendMotivasi(String isi) async {
    if (isi.isEmpty) {
      Flushbar(
        message: 'Motivasi tidak boleh kosong',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    Map<String, dynamic> body = {
      "isi_motivasi": isi,
      "iduser": widget.iduser ?? '',
    };

    try {
      final response = await dio.post(
        "/vigenesia/api/dev/POSTmotivasi/",
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        Flushbar(
          message: "Berhasil Submit",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.greenAccent,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);

        setState(() {
          ass.insert(
            0,
            MotivasiModel(
              isiMotivasi: isi,
              idUser: widget.iduser ?? '',
              id: '',
              tanggalInput: DateTime.now(),
              tanggalUpdate: '', // Set submission time
            ),
          );
        });
        isiController.clear();
      } else {
        Flushbar(
          message: "Gagal Submit",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      print("Error: $e");
      Flushbar(
        message: "Terjadi kesalahan: $e",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> putMotivasi(String idMotivasi, String isi) async {
    if (isi.isEmpty) {
      Flushbar(
        message: 'Motivasi tidak boleh kosong',
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    Map<String, dynamic> body = {
      "id": idMotivasi,
      "isi_motivasi": isi,
    };

    try {
      final response = await dio.put(
        "/vigenesia/api/dev/PUTmotivasi/",
        data: body,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        Flushbar(
          message: "Berhasil Mengupdate Motivasi",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.greenAccent,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
        _fetchMotivasiList(); // Refresh data setelah update
      } else {
        Flushbar(
          message: "Gagal Mengupdate Motivasi",
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      print("Error: $e");
      Flushbar(
        message: "Terjadi kesalahan: $e",
        duration: Duration(seconds: 2),
        backgroundColor: Colors.redAccent,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _fetchMotivasiList() async {
    try {
      List<MotivasiModel> data = await getData();
      setState(() {
        ass = data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Tidak ada tanggal';
    }
    // Format the DateTime to show only the date (without time)
    return DateFormat('yyyy-MM-dd').format(dateTime); // Only date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hallo, ${widget.nama}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    child: Icon(Icons.logout),
                    onPressed: () {
                      Navigator.pushReplacement(
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
                  hintText: "Tulis motivasi Anda...",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendMotivasi(isiController.text);
                },
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<MotivasiModel>>(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Terjadi kesalahan: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("Belum ada motivasi yang tersedia"),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var motivasi = snapshot.data![index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: ListTile(
                              title: Text(
                                  motivasi.isiMotivasi ?? "Motivasi kosong"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("User ID: ${motivasi.idUser}"),
                                  Text(
                                    "Tanggal Submit: ${formatDate(motivasi.tanggalInput)}", // Only show the date
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPage(
                                        id: motivasi.id,
                                        isiMotivasi: motivasi.isiMotivasi,
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    _fetchMotivasiList();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
