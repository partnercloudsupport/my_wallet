import 'package:my_wallet/firebase/firebase_common.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:w3c_event_source/w3c_event_source.dart';

FirebaseApp _app;

String _url(String path, {dynamic isEqualTo, dynamic startAt, dynamic endAt, String orderBy}) {
  var projectId = _app.options.projectID;

  var query = <String, String>{};
  if(isEqualTo != null) query.putIfAbsent("equalTo", () => "\"$isEqualTo\"");
  if(startAt != null) query.putIfAbsent("startAt", () => "$startAt");
  if(endAt != null) query.putIfAbsent("endAt", () => "$endAt");
  
  if(query.isNotEmpty) query.putIfAbsent("orderBy", () => "\"$orderBy\"");

  return Uri.https("$projectId.firebaseio.com", "$path.json", query.isEmpty ? null : query).toString();
}

var _headers = {"auth": token};

class FirebaseDatabase {
  FirebaseDatabase({FirebaseApp app}) : assert(app != null) {
    _app = app;
  }

  void settings({bool timestampsInSnapshotsEnabled}) {}

  CollectionReference collection(String path) {
    return CollectionReference(path: path);
  }
}

class CollectionReference extends Query {
  CollectionReference({String path}) : super(path: path);

  DocumentReference document([String path]) {
    return DocumentReference(path: path == null ? this.path : "${this.path}/$path");
  }
}

class DocumentReference extends Query {
  DocumentReference({String path}) : super(path: path);

  Future<DocumentSnapshot> get() async {
    // run a get query here
    var response = await http.get(_url(path), headers: _headers);

    if (response.statusCode == 200) {
      return DocumentSnapshot(documentID: "${path.substring(path.lastIndexOf("/")).replaceFirst("/", "")}", data: jsonDecode(response.body));
    }

    // failed, what to do?
    return null;
  }
}

class DocumentSnapshot {
  const DocumentSnapshot({this.documentID, this.data, this.reference});

  final String documentID;
  final Map<String, dynamic> data;
  final DocumentReference reference;
}

class DocumentChange {
  final DocumentSnapshot document;
  final DocumentChangeType type;

  DocumentChange({@required this.document, @required this.type});
}

class QuerySnapshot {
  List<DocumentSnapshot> _documents;
  List<DocumentChange> _documentChanges;

  get documentChanges => _documentChanges;
  get documents => _documents;
}

class Query {
  final String path;
  dynamic isEqualTo;
  dynamic startAt;
  dynamic endAt;
  String orderBy;

  Query({this.path});

  Query where(String key, {dynamic isEqualTo, dynamic startAt, dynamic endAt}) {
    this.isEqualTo = isEqualTo;
    this.startAt = startAt;
    this.endAt = endAt;
    this.orderBy = key;

    return this;
  }

  Future<QuerySnapshot> getDocuments() async {
    var headers = _headers;

    debugPrint("path ${_url(path, isEqualTo: isEqualTo, startAt: startAt, endAt: endAt, orderBy: orderBy)}");
    var response = await http.get(_url(path, isEqualTo: isEqualTo, startAt: startAt, endAt: endAt, orderBy: orderBy), headers: headers);

    if(response.statusCode != 200) {
      throw http.ClientException(response.reasonPhrase);
    }

    var snapshot = QuerySnapshot();

    snapshot._documents = [];

    Map<dynamic, dynamic> map = jsonDecode(response.body);

    map.forEach((key, value) => snapshot._documents.add(DocumentSnapshot(documentID: key, data: value)));

    return snapshot;
  }

  CollectionReference collection(String path) {
    return CollectionReference(path: "${this.path}/$path");
  }

  Future<void> setData(Map<String, dynamic> data) async {
    var headers = _headers;
    headers.putIfAbsent("Content-Type", () => "application/json");

    var response = await http.patch(_url(path), headers: headers, body: jsonEncode(data));

    debugPrint(jsonEncode(data));
    debugPrint(_url(path));
    if (response.statusCode != 200) {
      throw http.ClientException(response.reasonPhrase);
    }
  }

  Future<void> delete() async {
    var response = await http.delete(_url(path), headers: _headers);

    if (response.statusCode != 200) {
      throw http.ClientException(response.reasonPhrase);
    }
  }

  Stream<QuerySnapshot> snapshots() {
    final event = EventSource(Uri.parse(_url(path)));

    return event.events.transform(StreamTransformer.fromHandlers(
        handleData: (s, sink) {
          if(s.data != null) {
            var snapshot = QuerySnapshot();
            snapshot._documentChanges = [];

            Map map = jsonDecode(s.data);

            if(map != null && map.isNotEmpty) {
              String dataPath = map['path'];

              var type;
              var change;
              String id;
              if(map['data'] == null) {
                if(dataPath != "/") {
                  type = DocumentChangeType.removed;
                  change = null;
                  id = dataPath.substring(dataPath.lastIndexOf("/")).replaceAll("/", "");
                  debugPrint("data at $dataPath with ID $id is deleted");

                  snapshot._documentChanges.add(DocumentChange(document: DocumentSnapshot(documentID: id, data: change), type: type));
                }
              } else {
                var dataValue = map['data'];

                if(dataValue is List) {
                  List list = dataValue;

                  for (int i = 0; i < list.length; i++) {
                    id = "$i";
                    change = list[i];
                    snapshot._documentChanges.add(DocumentChange(document: DocumentSnapshot(documentID: id, data: change), type: change == null ? DocumentChangeType.removed : DocumentChangeType.added));
                  }
                } else if(dataValue is Map) {
                  if(dataPath == "/") {
                    dataValue.forEach((key, value) {
                      id = key;
                      change = value;
                      snapshot._documentChanges.add(DocumentChange(document: DocumentSnapshot(documentID: id, data: change), type: change == null ? DocumentChangeType.removed : DocumentChangeType.added));
                    });
                  } else {
                    id = dataPath.replaceFirst("/", "").split("/")[0];
                    change = dataValue;
                    snapshot._documentChanges.add(DocumentChange(document: DocumentSnapshot(documentID: id, data: change), type: change == null ? DocumentChangeType.removed : DocumentChangeType.added));
                  }
                } else {
                  type = DocumentChangeType.modified;
                  var split = dataPath.replaceFirst("/", "").split("/");
                  id = split[0];

                  change = {
                    split[1] : dataValue
                  };
                  snapshot._documentChanges.add(DocumentChange(document: DocumentSnapshot(documentID: id, data: change), type: change == null ? DocumentChangeType.removed : DocumentChangeType.modified));
                }

              }
              sink.add(snapshot);
            }
          }
    }));
  }
}

enum DocumentChangeType { added, modified, removed }
