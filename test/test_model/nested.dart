/*
 * This file is part of the mintware.dart_json package.
 *
 * Copyright 2018 - present by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

import 'dart:collection';

class NestedItem {
  String name;
  List<NestedItem> childItems;
}

class Nested {
  String firstName;
  int age;
  double height;
  bool activated;
  List<int> codes;
  HashMap<String, String> otherFields;

  // Nested fields
  List<List<int>> listList;
  List<HashMap<String, String>> listMap;

  HashMap<String, List<int>> mapList;
  HashMap<String, HashMap<String, String>> mapMap;

  // Object
  NestedItem item;
}
