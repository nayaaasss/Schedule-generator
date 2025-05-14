import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/models/task.dart';

class GeminiServices {
  /*base url itu sama kecuali url API nya yang ada di .ENV
  untuk gerbang komunikasi awal antara 
  client ---> si kode project atau aplikais yang telah di deploy
  dan 
  server ---> si Gemini APi
  */
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  final String apiKey;

  // ini adalah sebuah ternary operator untuk memastikan
  // apakah nilai dari API KEY tersedia atau kosng
  GeminiServices() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" { //sebelum titik dua itu adalah kondisi dan jika true maka ambil gemini_api_key
    if (apiKey.isEmpty) {
      throw ArgumentError("Please input your API KEY");
    }
  }

  // Logika untuk generating result dari input/prompt yang di berikan
  // yang akan di otomasi oleh AI API
  Future<String> generateSchedule(List<Task> tasks) async {
    //jika static maka di tandai _ (underscore) di depannya
    _validateTasks(tasks);
    //variable yang digunakan untuk menampung prompt request yang akan di eksekusi oleh AI
    final prompt = _buildPrompt(tasks);

    //blok try ini sebagai percobaan pengiriman request ke AI
    try {
      print("Prompt: \n$prompt");

      //variable yang digunakan untuk menampung respon dri request ke API AI
      //ketika cocok dia akan melempar respon yang di inginkan
      final response = await http.post(
        //ini adalah starting (awal mula) point untuk penggunaan endpoint dari APi dengan menggunakan Uri.parse
        //Uri.parse si url
        Uri.parse("$_baseUrl?key=$apiKey"),
        //
        headers: {
          "Content-Type": "application/json"
        },
        //maksud dri endcode adalah masih ngajak dan kita mau nuangin lebih rapih agar bisa menerima dri AI
        //ini yang awalnya tidak rapih
        body: jsonEncode({
          "contents": [
            {
            //role disini maksudnya adalah seseorang yang memberikan instruksi kpd AI melalui prompt
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        })
      );
      //umpan balik jika promptnya oke
      //code ini juga berkaitan dengan code yang ada di postman seperti 200, 400 dll
      return _handleResponse(response);
      //jika tidak ada respons dan gagal
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }

  //ini adalah fungsi yang digunakan untuk menghandle respon dari API AI
  String _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    /*
    swicth case ini adalah ekspresi yang akan di cek yang di cek adalah status code dri http
    ini juga salah satu cabang dari perkondisian yang berisi statement general yang dapat di eksekusi
    oleh berbagai macam action (case) tanpa harus bergantung pada single-statement yang dimiliki oleh setiap 
    action yg ada pada parameter case.

    ini di wajibkan untuk implement jika kalian mengambil dri APi
    */
    switch (response.statusCode) { //code yg berwarna biru itu namanya statement general bisa di ekskusi jd dia puny mutiple case yg penting dia punay kembalian
      case 200:
        return data["candidates"][0]["content"]["parts"][0]["text"];
      case 404:
        throw ArgumentError("Server not found");
      case 500:
        throw ArgumentError("Internal server error");
      default:
        throw ArgumentError("Unknown Error: ${response.statusCode}");
    }
  }

  String _buildPrompt(List<Task> tasks) {
    //berfungsi untuk men setting format tanggal dan waktu lokal (indonesia)
    initializeDateFormatting();
    final dateFormatter = DateFormat("dd mm yyyy 'pukul' hh:mm, 'id_ID' ");

    final taskList = tasks.map((task) {
      final formatDeadline = dateFormatter.format(task.deadline);
      
      return "- ${task.name} (Duration: ${task.duration} minutes, Deadline: $formatDeadline)";
      //TODO: panggil semua variable yang akan di proses oleh ai
    });

    /*
    menggunakan framework R-T-A (Roles-Task_action) untuk prmpting
    */
    //ini untuk menggunakan mutiple line text ini namanya tripel apostrop jdi tidak perlu memakai \n
    return '''
    Saya adalah seorang siswa, dan saya memiliki daftar sebagai berikut:
    $taskList
    Tolong susun jadwal yang optimal dan efisien berdasarkan daftar tugas tersebut .
    Tolong tentukan prioritasnya berdasarkan *Deadline yang paling dekat* dan *durasi tugas*
    Tolong buat jadwal yang sistematis dari pagi hari, sampai malam hari.
    Tolong pastikan semua tugas dapat selesai sebelum deadline.

    Tolong buatkan ouput jadwal dalam format list per jam, misalnya:
    - 07:00 - 08.00 : Melaksanakan piket kamar
    ''';
  }

  void _validateTasks(List<Task> tasks) {
    //ini merupakan bentuk dari single statement dari if-else condition
    if (tasks.isEmpty) throw ArgumentError("Please input your task before generating");
  }
}