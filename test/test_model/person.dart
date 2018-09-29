/*
 * This file is part of the Mintware.DartJson package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'package:dart_json/dart_json.dart';

class Person {
  @JsonProperty("first_name")
  String firstName;

  String lastName;
  int age;
  double height;
  List<String> colors;
  Map<String, String> nicks;
  bool isCool;
  String additional;
}
