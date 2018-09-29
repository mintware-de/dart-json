[![GitHub license](https://img.shields.io/github/license/mintware-de/dart-json.svg)](https://github.com/mintware-de/dart-json/blob/master/LICENSE)
[![Travis](https://img.shields.io/travis/mintware-de/dart-json.svg)](https://travis-ci.org/mintware-de/dart-json)
[![Pub](https://img.shields.io/pub/v/dart-json.svg)](https://pub.dartlang.org/packages/dart-json)
[![Coverage Status](https://coveralls.io/repos/github/mintware-de/dart-json/badge.svg?branch=master)](https://coveralls.io/github/mintware-de/dart-json?branch=master)

# DartJson

DartJson is a JSON to object mapper.

- It's fast
- dependency-less
- works with nested objects
- property names in classes can be different to the name in the json 

## 📦 Installation
Add the following to your `pubspec.yaml`:
```yaml
dependencies:
  dart_json: ^1.0.0
```

Then run `pub get`

## 💡 Usage

### Importing
```dart
import 'package:dart_json/dart_json.dart';
```

### Using it
```dart
import 'package:dart_json/dart_json.dart';

class Person {
  @JsonProperty("first_name")
  String firstName;

  String lastName;

  int age;
}

void main() {
  var json = '{"first_name": "Max", "lastName": "Mustermann", "age": 25}';
  Person p = Json.deserialize<Person>(json);
  print(p.firstName); // Max
  print(p.lastName); // Mustermann
  print(p.age); // 25

  var newJson = Json.serialize(p);
  print(newJson); // {"first_name":"Max","lastName":"Mustermann","age":25}
}
```

## 🔬 Testing

```bash
$ pub run test
```

## 🤝 Contribute
Feel free to fork and add pull-requests 🤓