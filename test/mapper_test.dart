/*
 * This file is part of the Mintware.DartJson package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';

import 'package:dart_json/dart_json.dart';

import 'package:test/test.dart';

import 'test_model/nested.dart';
import 'test_model/person.dart';

void main() {
  test('Test map simple data', () {
    expect(Json.deserialize<String>('""'), equals(""));
    expect(Json.deserialize<dynamic>('null'), isNull);
    expect(Json.deserialize<double>('2.7'), equals(2.7));
    expect(Json.deserialize<bool>('true'), isTrue);
    expect(Json.deserialize<bool>('false'), isFalse);

    var lInt = new List<int>();
    lInt.addAll([1, 2, 3, 4]);
    expect(Json.deserialize<List<int>>('[1,2,3, 4]'), equals(lInt));
    var mapRes = Json.deserialize<HashMap<String, int>>('{"hallo": 1}');
    expect(mapRes, equals({"hallo": 1}));
  });

  test('Map simple object to class', () {
    Person mapped = Json.deserialize<Person>('''{
  "firstName": "Max",
  "lastName": "Mustermann",
  "age": 18,
  "height": 1.88,
  "colors": ["red", "green"],
  "nicks": {
    "site1": "mustermann.max",
    "site2": "max"
  },
  "isCool": true,
  "additional": null
}''');

    expect(mapped.firstName, equals("Max"));
    expect(mapped.lastName, equals("Mustermann"));
    expect(mapped.age, equals(18));
    expect(mapped.height, equals(1.88));
    expect(mapped.colors, equals(["red", "green"]));
    expect(mapped.nicks, equals({"site1": "mustermann.max", "site2": "max"}));
    expect(mapped.isCool, isTrue);
    expect(mapped.additional, isNull);
  });

  test('Map collection of objects to class', () {
    List<Person> mapped = Json.deserialize<List<Person>>('''[{
  "firstName": "Max",
  "lastName": "Mustermann",
  "age": 18,
  "height": 1.88,
  "colors": ["red", "green"],
  "nicks": {
    "site1": "mustermann.max",
    "site2": "max"
  },
  "isCool": true,
  "additional": null
}, {
  "firstName": "Maria",
  "lastName": "Musterfrau",
  "age": 19,
  "height": 1.75,
  "colors": ["pink"],
  "nicks": {
    "site1": "maria.pink"
  },
  "isCool": true,
  "additional": "some note"
}]''');

    expect(mapped, isList);
    expect(mapped, hasLength(2));

    expect(mapped[0].firstName, equals("Max"));
    expect(mapped[0].lastName, equals("Mustermann"));
    expect(mapped[0].age, equals(18));
    expect(mapped[0].height, equals(1.88));
    expect(mapped[0].colors, equals(["red", "green"]));
    expect(
        mapped[0].nicks, equals({"site1": "mustermann.max", "site2": "max"}));
    expect(mapped[0].isCool, isTrue);
    expect(mapped[0].additional, isNull);

    expect(mapped[1].firstName, equals("Maria"));
    expect(mapped[1].lastName, equals("Musterfrau"));
    expect(mapped[1].age, equals(19));
    expect(mapped[1].height, equals(1.75));
    expect(mapped[1].colors, equals(["pink"]));
    expect(mapped[1].nicks, equals({"site1": "maria.pink"}));
    expect(mapped[1].isCool, isTrue);
    expect(mapped[1].additional, equals("some note"));
  });

  test('Nesting', () {
    Nested mapped = Json.deserialize<Nested>('''{
  "firstName": "Peter",
  "age": 33,
  "height": 1.98,
  "activated": true,
  "codes": [2, 4, 5],
  "otherFields": {
    "job": "developer",
    "zipCode": "1234"
  },
  "listList": [
    [1, 3, 5],
    [2, 4, 6]
  ],
  "listMap": [
    {"make": "Audi"},
    {"make": "Portsche", "color": "black"}
  ],
  "mapList": {
    "luckyNumbers": [7, 11]
  },
  "mapMap": {
    "primary": {"dark": "dark-red", "light": "light-red"},
    "secondary": {"bg": "gray"}
  },
  "item": {
    "name": "All",
    "childItems": [
      {
        "name": "Cars",
        "childItems": [
          {
            "name": "Premium",
            "childItems": []
          }
        ]
      },
      {
        "name": "Bikes",
        "childItems": []
      }
    ]
  },
  "nonExistent": null
}''');
    expect(mapped.firstName, equals("Peter"));
    expect(mapped.age, equals(33));
    expect(mapped.activated, isTrue);
    expect(mapped.codes, equals([2, 4, 5]));
    expect(mapped.otherFields, equals({"job": "developer", "zipCode": "1234"}));
    expect(
        mapped.listList,
        equals([
          [1, 3, 5],
          [2, 4, 6]
        ]));
    expect(
        mapped.listMap,
        equals([
          {"make": "Audi"},
          {"make": "Portsche", "color": "black"}
        ]));
    expect(
        mapped.mapList,
        equals({
          "luckyNumbers": [7, 11]
        }));
    expect(
        mapped.mapMap,
        equals({
          "primary": {"dark": "dark-red", "light": "light-red"},
          "secondary": {"bg": "gray"}
        }));

    expect(mapped.item.name, equals("All"));
    expect(mapped.item.childItems, hasLength(2));
    expect(mapped.item.childItems[0].name, equals("Cars"));
    expect(mapped.item.childItems[0].childItems, hasLength(1));
    expect(mapped.item.childItems[0].childItems[0].name, equals("Premium"));
    expect(mapped.item.childItems[0].childItems[0].childItems, hasLength(0));
    expect(mapped.item.childItems[1].name, equals("Bikes"));
    expect(mapped.item.childItems[1].childItems, hasLength(0));
  });

  test('Map with annotation', () {
    Person mapped = Json.deserialize<Person>('''{
  "first_name": "Max",
  "lastName": "Mustermann",
  "age": 18,
  "height": 1.88,
  "colors": ["red", "green"],
  "nicks": {
    "site1": "mustermann.max",
    "site2": "max"
  },
  "isCool": true,
  "additional": null
}''');

    expect(mapped.firstName, equals("Max"));
    expect(mapped.lastName, equals("Mustermann"));
    expect(mapped.age, equals(18));
    expect(mapped.height, equals(1.88));
    expect(mapped.colors, equals(["red", "green"]));
    expect(mapped.nicks, equals({"site1": "mustermann.max", "site2": "max"}));
    expect(mapped.isCool, isTrue);
    expect(mapped.additional, isNull);
  });

  test('Test serialize simple data', () {
    expect(Json.serialize(""), equals('""'));
    expect(Json.serialize(null), equals("null"));
    expect(Json.serialize(2.7), equals("2.7"));
    expect(Json.serialize(true), equals("true"));
    expect(Json.serialize(false), equals("false"));

    var lInt = new List<int>();
    lInt.addAll([1, 2, 3, 4]);
    expect(Json.serialize(lInt), equals('[1,2,3,4]'));
    var mapRes = Json.serialize({"hallo": 1});
    expect(mapRes, equals('{"hallo":1}'));
  });

  test('Test serialize object', () {
    var p = new Person();
    p.firstName = "Max";
    p.lastName = "Mustermann";
    p.age = 23;
    p.height = 1.53;
    p.colors = ["Red", "Blue"];
    p.nicks = {"foo": "bar", "bar": "baz"};
    p.isCool = false;
    p.additional = null;

    var expectedJson =
        '{"first_name":"Max","lastName":"Mustermann","age":23,"height":1.53,"colors":["Red","Blue"],"nicks":{"foo":"bar","bar":"baz"},"isCool":false,"additional":null}';

    expect(Json.serialize(p), equals(expectedJson));
  });

  test('Test serialize list of object', () {
    var p = new Person();
    p.firstName = "Max";
    p.lastName = "Mustermann";
    p.age = 23;
    p.height = 1.53;
    p.colors = ["Red", "Blue"];
    p.nicks = {"foo": "bar", "bar": "baz"};
    p.isCool = false;
    p.additional = null;

    var expectedJson =
        '[{"first_name":"Max","lastName":"Mustermann","age":23,"height":1.53,"colors":["Red","Blue"],"nicks":{"foo":"bar","bar":"baz"},"isCool":false,"additional":null}]';

    expect(Json.serialize([p]), equals(expectedJson));
  });

  test('Test serialize pretty print', () {
    var p = new Person();
    p.firstName = "Max";
    p.lastName = "Mustermann";
    p.age = 23;
    p.height = 1.53;
    p.colors = ["Red", "Blue"];
    p.nicks = {"foo": "bar", "bar": "baz"};
    p.isCool = false;
    p.additional = null;

    var expectedJson = '''{
  "first_name": "Max",
  "lastName": "Mustermann",
  "age": 23,
  "height": 1.53,
  "colors": [
    "Red",
    "Blue"
  ],
  "nicks": {
    "foo": "bar",
    "bar": "baz"
  },
  "isCool": false,
  "additional": null
}''';

    expect(Json.serialize(p, prettyPrint: true), equals(expectedJson));
  });
}
