/*
 * This file is part of the Mintware.DartJson package.
 *
 * Copyright 2018 by Julian Finkler <julian@mintware.de>
 *
 * For the full copyright and license information, please read the LICENSE
 * file that was distributed with this source code.
 */

part of Mintware.DartJson;

/// A JSON deserialize library
class Json {
  /// Deserialize a [json] string to a object
  ///
  /// Returns a object of type [T]
  static T deserialize<T>(String json) {
    var res = jsonDecode(json);

    dynamic mapped = null;
    if (res == null ||
        (_isSubtypeOf(T, String) && res is String) ||
        (_isSubtypeOf(T, int) && res is int) ||
        (_isSubtypeOf(T, double) && res is double) ||
        (_isSubtypeOf(T, bool) && res is bool)) {
      mapped = res;
    } else if (_isSubtypeOf(T, List) && _isSubtypeOf(res.runtimeType, List)) {
      mapped = _mapList(T, res);
    } else if (_isSubtypeOf(T, Map) && _isSubtypeOf(res.runtimeType, Map)) {
      mapped = _mapMap(T, res);
    } else {
      mapped = _mapObject(T, res);
    }

    return mapped;
  }

  /// Checks using reflection if  [T1] is a subtype of [T2]
  static bool _isSubtypeOf(Type T1, Type T2) {
    var res = reflectType(T1).isSubtypeOf(reflectType(T2));
    return res;
  }

  /// Maps a list
  static List _mapList(Type t, List l) {
    var instType = _getTypeArgs(t);
    var mirror = (reflectType(List, [instType[0]]) as ClassMirror);

    var ref = mirror.newInstance(const Symbol(''), []);

    List list = ref.reflectee;
    l.forEach((entry) => list.add(_handleEntry(instType[0], entry)));
    return list;
  }

  /// Gets the type arguments for the given Type [T]
  ///
  /// Returns the type arguments as a List<Type>
  static List<Type> _getTypeArgs(Type T) {
    var typeArgs = new List<Type>();
    reflectType(T).typeArguments.forEach((t) => typeArgs.add(t.reflectedType));
    return typeArgs;
  }

  /// Handles a single entry
  static dynamic _handleEntry(Type instType, dynamic entry) {
    var eType = entry.runtimeType;

    dynamic res = null;
    if (instType == dynamic ||
        instType == Null ||
        (instType == String && (eType == String || eType == Null)) ||
        (instType == int && (eType == int || eType == Null)) ||
        (instType == double && (eType == double || eType == Null)) ||
        (instType == bool && (eType == bool || eType == Null))) {
      res = entry;
    } else if (_isSubtypeOf(eType, List) && _isSubtypeOf(instType, List)) {
      res = _mapList(instType, entry);
    } else if (_isSubtypeOf(eType, Map) && !_isSubtypeOf(instType, Map)) {
      res = _mapObject(instType, entry);
    } else if (_isSubtypeOf(eType, Map) && _isSubtypeOf(instType, Map)) {
      res = _mapMap(instType, entry);
    } else {
      throw Exception("Can not map '${eType}' to '$instType' on '$entry'");
    }

    return res;
  }

  /// Maps a map
  static Map _mapMap(Type t, Map entries) {
    var typeArgs = _getTypeArgs(t);
    var mirror = (reflectType(t, typeArgs) as ClassMirror);
    Map m = mirror.newInstance(const Symbol(''), []).reflectee;

    entries.forEach((k, entry) => m[k] = _handleEntry(typeArgs[1], entry));
    return m;
  }

  /// Maps the [jsonData] to the given Type [T]
  ///
  /// Members in the [jsonData] which does not exist on [T] will be ignored
  static dynamic _mapObject(Type T, LinkedHashMap jsonData) {
    var clsMirror = (reflectType(T) as ClassMirror);
    var instanceMirror = clsMirror.newInstance(const Symbol(''), []);
    dynamic instance = instanceMirror.reflectee;

    var declarations = clsMirror.declarations.values;
    var variableMirrors = declarations.where((d) => d is VariableMirror);

    jsonData.forEach((k, v) {
      var property = _getProperty(k, variableMirrors);
      if (property == null) return;

      var propertyType = (property as VariableMirror);
      var instType = propertyType.type.reflectedType;

      instanceMirror.setField(property.simpleName, _handleEntry(instType, v));
    });

    return instance;
  }

  /// Gets a class member by [name]
  ///
  /// Returns the DeclarationMirror
  static DeclarationMirror _getProperty(
      String name, Iterable<DeclarationMirror> variableMirrors) {
    var declaration = variableMirrors.firstWhere(
        (d) => MirrorSystem.getName(d.simpleName) == name,
        orElse: () => null);

    if (declaration == null) {
      declaration = variableMirrors.firstWhere((d) {
        var annotations = _getAnnotations<JsonProperty>(d);
        return annotations.length > 0 &&
            annotations.where((m) => m.name == name).length > 0;
      }, orElse: () => null);
    }

    return declaration;
  }

  /// Gets the annotations of a specific type for a declaration mirror
  static List<T> _getAnnotations<T>(DeclarationMirror d) {
    var annotations = new List<T>();
    d.metadata.where((m) => m.hasReflectee && m.reflectee is T).forEach((e) {
      annotations.add(e.reflectee);
    });
    return annotations;
  }

  /// Serializes a object to json
  static String serialize(dynamic object, {bool prettyPrint = false}) {
    var mapped = _prepareEntry(object.runtimeType, object);

    JsonEncoder encoder = new JsonEncoder();
    if (prettyPrint) encoder = new JsonEncoder.withIndent('  ');

    return encoder.convert(mapped);
  }

  /// Prepares a entry for serialization
  static dynamic _prepareEntry(Type t, dynamic val) {
    if (val == null ||
        (_isSubtypeOf(t, String)) ||
        (_isSubtypeOf(t, int)) ||
        (_isSubtypeOf(t, double)) ||
        (_isSubtypeOf(t, bool))) {
      return val;
    } else if (_isSubtypeOf(t, List)) {
      return _prepareList(val);
    } else if (_isSubtypeOf(t, Map)) {
      return _prepareMap(val);
    } else {
      return _prepareObject(val);
    }
  }

  /// Prepares a object for serialization
  static Map<String, dynamic> _prepareObject(dynamic object) {
    var map = new Map<String, dynamic>();

    var mirror = reflect(object);

    var declarations = mirror.type.declarations.values;
    declarations.where((d) => d is VariableMirror).forEach((d) {
      var annotation = _getAnnotations<JsonProperty>(d).firstWhere(
          (p) => p.name != null && p.name != "",
          orElse: () => new JsonProperty());

      var name = annotation.name;

      if (name == null) {
        name = MirrorSystem.getName(d.simpleName);
      }

      var val = mirror.getField(d.simpleName).reflectee;
      var type = (d as VariableMirror).type.reflectedType;
      map[name] = _prepareEntry(type, val);
    });

    return map;
  }

  /// Prepares a list for serialization
  static List _prepareList(List val) {
    var map = new List();
    var typeArgs = _getTypeArgs(val.runtimeType);

    val.forEach((e) => map.add(_prepareEntry(typeArgs[0], e)));

    return map;
  }

  /// Prepares a map for serialization
  static Map _prepareMap(Map val) {
    var map = new Map<String, dynamic>();

    var typeArgs = _getTypeArgs(val.runtimeType);
    val.forEach((k, v) => map[k] = _prepareEntry(typeArgs[1], v));

    return map;
  }
}
