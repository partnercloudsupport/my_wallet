//import 'package:firebase_core/firebase_core.dart';
//export 'package:firebase_core/firebase_core.dart';
//
//import 'package:my_wallet/firebase/firebase_common.dart';
//import 'package:http/http.dart';
//
//import 'dart:convert';
//import 'dart:async';
//
//class Firestore {
//  FirebaseApp app;
//  bool timestampsInSnapshotsEnabled;
//
//  Firestore({this.app});
//
//  void settings({bool timestampsInSnapshotsEnabled}) {
//    this.timestampsInSnapshotsEnabled = timestampsInSnapshotsEnabled;
//  }
//
//  bool done = false;
//  CollectionReference collection(String path) {
//    if(!done) {
//      done = true;
//      var updateBody = json.encode({
//        "writes" : [ {
//          "update": {
//            "fields": {
//              "name": {
//                "stringValue": "testing update"
//              },
//            }
//          }
//        } ]
//      });
//
//      // sample code to update current document
//      post("https://firestore.googleapis.com/v1beta1/projects/mywallet-c3db6/databases/(default)/documents/data/testing/Account/10:commit", headers: {
//        "Authorization": "Bearer $token",
//        "Content-Type": "application/json"
//      }, body: updateBody).then((response) {
//        print("response ${response.statusCode}");
//        print("body: ${response.body}");
//      });
//    }
//    return CollectionReference(path: path);
//  }
//}
//
//class DocumentSnapshot {
//  String documentID;
//  Map<String, dynamic> data;
//  DocumentReference reference;
//
//  void setData(Map<String, dynamic> data) {
//    data.forEach((key, value) {
//      this.data.remove(key);
//      this.data.putIfAbsent(key, () => value);
//    });
//  }
//}
//
//class QuerySnapshot {
//  List<DocumentSnapshot> documents;
//  List<DocumentChange> documentChanges;
//
//}
//class CollectionReference extends Query {
//  CollectionReference({String path}) : super(path: path);
//
//  DocumentReference document([String path]) {
//    return DocumentReference(path: "${this.path}/$path");
//  }
//}
//
//class DocumentReference extends Query {
//  DocumentReference({String path}) : super(path: path);
//
//  CollectionReference collection(String path) {
//
//  }
//
//  Future<DocumentSnapshot> get() {
//
//  }
//
//  Future<void> setData(Map<String, dynamic> map) {
////    // sample document body to create/update data
////    var body = json.encode({
////      "fields": {
////        "amount": {
////          "integerValue": "120"
////        },
////        "name": {
////          "stringValue": "testing"
////        },
////        "currency": {
////          "stringValue": "\$"
////        },
////        "type": {
////          "integerValue": "0"
////        }
////      }
////    });
////    // sample code to create new document with data
////    post("https://firestore.googleapis.com/v1beta1/projects/mywallet-c3db6/databases/(default)/documents/data/testing/Account?documentId=10", headers: {
////      "Authorization": "Bearer $token",
////      "Content-Type": "application/json"
////    }, body: body).then((response) {
////      print("response ${response.statusCode}");
////      print("body: ${response.body}");
////    });
////
////    // sample code to create new document without data
////    post("https://firestore.googleapis.com/v1beta1/projects/mywallet-c3db6/databases/(default)/documents/data/testing/Account?documentId=10", headers: {
////      "Authorization": "Bearer $token",
////      "Content-Type": "application/json"
////    }).then((response) {
////      print("response ${response.statusCode}");
////      print("body: ${response.body}");
////    });
//
////    var updateBody = json.encode({
////      "writes" : [ {
////        "update": {
////          "fields": {
////            "amount": {
////              "integerValue": "120"
////            },
////            "name": {
////              "stringValue": "testing update"
////            },
////            "currency": {
////              "stringValue": "\$"
////            },
////            "type": {
////              "integerValue": "0"
////            }
////          }
////        }
////      } ]
////    });
////
////    // sample code to update current document
////    post("https://firestore.googleapis.com/v1beta1/projects/mywallet-c3db6/databases/(default)/documents/data/testing/Account/10:commit", headers: {
////      "Authorization": "Bearer $token",
////      "Content-Type": "application/json"
////    }, body: updateBody).then((response) {
////      print("response ${response.statusCode}");
////      print("body: ${response.body}");
////    });
//  }
//}
//
//class Query {
//  String path;
//
//  Query({String path}) {
//    this.path = path;
//  }
//
//  Query where(
//      String field, {
//        dynamic isEqualTo,
//        dynamic isLessThan,
//        dynamic isLessThanOrEqualTo,
//        dynamic isGreaterThan,
//        dynamic isGreaterThanOrEqualTo,
//        dynamic arrayContains,
//        bool isNull,
//      }) {
//  }
//
//  void delete() {
//
//  }
//
//  Future<QuerySnapshot> getDocuments() {
//
//  }
//
//  Stream<QuerySnapshot> snapshots() {
//    Future<int> _handle;
//    // It's fine to let the StreamController be garbage collected once all the
//    // subscribers have cancelled; this analyzer warning is safe to ignore.
//    StreamController<QuerySnapshot> controller; // ignore: close_sinks
//    controller = StreamController<QuerySnapshot>.broadcast(
//    onListen: () {
//      print("listening");
//    },
//
//    onCancel: () {
//      print("cancel");
//    }
//    );
////
////    controller = StreamController<QuerySnapshot>.broadcast(
////    onListen: () {
////    _handle = Firestore.channel.invokeMethod(
////    'Query#addSnapshotListener',
////    <String, dynamic>{
////    'app': firestore.app.name,
////    'path': _path,
////    'parameters': _parameters,
////    },
////    ).then<int>((dynamic result) => result);
////    _handle.then((int handle) {
////    Firestore._queryObservers[handle] = controller;
////    });
////    },
////    onCancel: () {
////    _handle.then((int handle) async {
////    await Firestore.channel.invokeMethod(
////    'Query#removeListener',
////    <String, dynamic>{'handle': handle},
////    );
////    Firestore._queryObservers.remove(handle);
////    });
////    },
////    );
//    return controller.stream;
//  }
//}
//
//class DocumentChange {
//  int oldIndex;
//  int newIndex;
//  DocumentSnapshot document;
//  DocumentChangeType type;
//}
//
///// An enumeration of document change types.
//enum DocumentChangeType {
//  /// Indicates a new document was added to the set of documents matching the
//  /// query.
//  added,
//
//  /// Indicates a document within the query was modified.
//  modified,
//
//  /// Indicates a document within the query was removed (either deleted or no
//  /// longer matches the query.
//  removed,
//}