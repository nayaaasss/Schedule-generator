/*
file yang berbeda di dalam folder model..
biasa disebut data class

biasanya, data class dipresentasikan dengan bundling
dengan mengimport libary parcelize =  miliknya android Native

nah disini kita mengisi data" yang akan di olah. 
TODO: jika kalian mau menambahkan image disini maka buat variable bru
*/

class Task {
  final String name;
  final int duration;
  final DateTime deadline;

  Task({required this.name, required this.duration, required this.deadline});
  
  //untuk membuat suatu turuanan dri object
  //salah satu contohnya adalah adanya function di dalam function
  @override
  String toString() {
    return "Task{name: $name, duration: $duration, deadline: $deadline}";
  }
}