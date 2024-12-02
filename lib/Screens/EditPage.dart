import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';

class EditPage extends StatefulWidget {
  final String? id;
  final String? isiMotivasi;

  const EditPage({Key? key, this.id, this.isiMotivasi}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String baseurl = "http://10.0.2.2"; // Ganti dengan URL backend Anda
  late Dio dio;
  TextEditingController isiMotivasiC = TextEditingController();

  @override
  void initState() {
    super.initState();
    dio = Dio();
    isiMotivasiC.text = widget.isiMotivasi ?? ''; // Pre-fill motivasi lama
  }

  Future<void> putMotivasi(String isiMotivasi, String id) async {
    if (isiMotivasi.isEmpty) {
      // Hanya menampilkan Flushbar jika motivasi kosong
      if (mounted) {
        Flushbar(
          message: "Isi motivasi tidak boleh kosong.",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
      return;
    }

    Map<String, dynamic> data = {
      "isi_motivasi": isiMotivasi,
      "id": id,
    };

    try {
      final response = await dio.put(
        '$baseurl/vigenesia/api/dev/PUTmotivasi',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        // Menampilkan Flushbar sukses
        if (mounted) {
          Flushbar(
            message: "Motivasi berhasil diupdate!",
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);

          // Delay sebelum navigasi
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            }
          });
        }
      } else {
        // Menampilkan Flushbar error jika gagal update
        if (mounted) {
          Flushbar(
            message: "Gagal mengupdate motivasi. Coba lagi.",
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      }
    } on DioError catch (e) {
      // Menampilkan Flushbar error jika terjadi kesalahan koneksi
      if (mounted) {
        Flushbar(
          message: "Kesalahan koneksi: ${e.message}",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      // Menampilkan Flushbar error untuk kesalahan umum
      if (mounted) {
        Flushbar(
          message: "Terjadi kesalahan. Coba lagi.",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  Future<dynamic> deleteMotivasi(String id) async {
    dynamic data = {
      "id": id,
    };
    try {
      var response = await dio.delete(
        '$baseurl/vigenesia/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {"Content-type": "application/json"},
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Flushbar(
            message: "Motivasi berhasil dihapus!",
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);

          // Delay sebelum navigasi
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.pop(
                  context); // Kembali ke halaman sebelumnya setelah delete
            }
          });
        }
      } else {
        if (mounted) {
          Flushbar(
            message: "Gagal menghapus motivasi. Coba lagi.",
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      }
    } on DioError catch (e) {
      if (mounted) {
        Flushbar(
          message: "Kesalahan koneksi: ${e.message}",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (mounted) {
        Flushbar(
          message: "Terjadi kesalahan. Coba lagi.",
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Motivasi"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Motivasi Lama:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                widget.isiMotivasi ?? "Data tidak ditemukan",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              FormBuilderTextField(
                name: "isi_motivasi",
                controller: isiMotivasiC,
                decoration: InputDecoration(
                  labelText: "Motivasi Baru",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  putMotivasi(isiMotivasiC.text, widget.id ?? '');
                },
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  deleteMotivasi(widget.id ?? '');
                },
                child: Text("Delete Motivasi"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Red button for delete
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
