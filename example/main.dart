import 'package:dart_json/dart_json.dart';

class Person {
  @JsonProperty("first_name")
  String? firstName;

  String? lastName;

  int? age;
}

void main() {
  var json = '{"first_name": "Max", "lastName": "Mustermann", "age": 25}';
  Person p = Json.deserialize<Person>(json)!;
  print(p.firstName); // Max
  print(p.lastName); // Mustermann
  print(p.age); // 25

  var newJson = Json.serialize(p);
  print(newJson); // {"first_name":"Max","lastName":"Mustermann","age":25}
}
