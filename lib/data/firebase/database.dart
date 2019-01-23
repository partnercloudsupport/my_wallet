import 'dart:async';

import 'package:my_wallet/data/database_manager.dart' as db;
import 'package:my_wallet/data/firebase/common.dart';
import 'package:my_wallet/firebase/database/firebase_database.dart';

const _data = "data";

DocumentReference _firestore;

bool _isInit = false;
bool _isDbSetup = false;

FirebaseApp _app;

Map<String, StreamSubscription> subs = {};
Timer _timerSync;

Future<void> init(FirebaseApp app, {String homeProfile}) async {
  if (_isInit) return;

  _isInit = true;
  if(_app != null) _app = app;

  if (homeProfile != null && homeProfile.isNotEmpty) await setupDatabase(homeProfile);
}

Future<void> dispose() {
  return _lock.synchronized(() {
    _unsubscribe();
  });
}

Future<void> resume() {
  return _lock.synchronized(() => _addSubscriptions());
}

Future<void> setupDatabase(final String homeKey) async {
  return _lock.synchronized(() async {
    if (_isDbSetup) return;

    _isDbSetup = true;

    _firestore = (await firestore(_app)).collection(_data).document(homeKey);

    DocumentSnapshot snapShot;
    try {
        snapShot = await _firestore.get();
    } catch (e) {
      print("timeout on homekey data");
    }

    if(snapShot == null || snapShot.documentID == null || snapShot.documentID.isEmpty) {
      print("drop all table");
      // drop database
      await db.dropAllTables();
    }

    await _addSubscriptions();
  });
}

Future<void> _addSubscriptions() async {
  subs.putIfAbsent(tblAccount, () => _firestore.collection(tblAccount).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onAccountAdded(change.document); break;
      case DocumentChangeType.modified: _onAccountChanged(change.document); break;
      case DocumentChangeType.removed: _onAccountRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblBudget, () =>_firestore.collection(tblBudget).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onBudgetAdded(change.document); break;
      case DocumentChangeType.modified: _onBudgetChanged(change.document); break;
      case DocumentChangeType.removed: _onBudgetRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblCategory, () => _firestore.collection(tblCategory).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onCategoryAdded(change.document); break;
      case DocumentChangeType.modified: _onCategoryChanged(change.document); break;
      case DocumentChangeType.removed: _onCategoryRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblTransaction, () => _firestore.collection(tblTransaction).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onTransactionAdded(change.document); break;
      case DocumentChangeType.modified: _onTransactionChanged(change.document); break;
      case DocumentChangeType.removed: _onTransactionRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblUser, () => _firestore.collection(tblUser).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onUserAdded(change.document); break;
      case DocumentChangeType.modified: _onUserChanged(change.document); break;
      case DocumentChangeType.removed: _onUserRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblTransfer, () => _firestore.collection(tblTransfer).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onTransferAdded(change.document); break;
      case DocumentChangeType.modified: _onTransferChanged(change.document); break;
      case DocumentChangeType.removed: _onTransferRemoved(change.document); break;
    }
  })));

  subs.putIfAbsent(tblDischargeOfLiability, () => _firestore.collection(tblDischargeOfLiability).snapshots().listen((f) => f.documentChanges.forEach((change) {
    switch(change.type) {
      case DocumentChangeType.added: _onDischargeOfLiabilityAdded(change.document); break;
      case DocumentChangeType.modified: _onDischargeOfLiabilityChanged(change.document); break;
      case DocumentChangeType.removed: _onDischargeOfLiabilityRemoved(change.document); break;
    }
  })));

  _delaySync(initiate: true);
}

//Future<void> _sync(
//    List<int> items,
//    String table,
//    Function(DocumentSnapshot snapshot) onUpdated) async {
//  for(int id in items) {
//    var snapshot = await _firestore.collection(table).document("$id").get();
//
//    onUpdated(snapshot);
//  }
//}

void _delaySync({bool initiate = false}) {
  if(!initiate) {
    if (_timerSync == null) return;
    if (!_timerSync.isActive) return;

    _timerSync.cancel();
  }

  _timerSync = new Timer(Duration(seconds: 1), () async {
    Map<String, String> tables = {
      tblAccount : "table_accounts",
      tblTransaction : "table_transactions",
      tblCategory : "table_categories",
      tblUser : "table_user",
      tblBudget : "table_budget",
      tblTransfer : "table_transfer"
    };
    for(String table in tables.keys) {
      List<String> ids = await db.queryOutOfSync(table);
      if(ids != null && ids.isNotEmpty) {
        for(String id in ids) {
          var snapshot = await _firestore.collection(table).document(id).get();

          // only care of deleted items
          if(snapshot.data == null) {
            print("table $table has item ${snapshot.documentID} deleted");

            switch(table) {
              case tblAccount: db.deleteAccount(_toId(snapshot)); break;
              case tblTransaction: db.deleteTransaction(_toId(snapshot)); break;
              case tblCategory: db.deleteCategory(_toId(snapshot)); break;
              case tblUser: db.deleteUser(snapshot.documentID); break;
              case tblTransfer: db.deleteTransfer(_toId(snapshot)); break;
              case tblBudget: db.deleteBudget(_toId(snapshot)); break;
            }
          }
        }
      }
    }

    // remove this timer after sync is done
    _timerSync = null;
  });
}

// ####################################################################################################
// private helper
Map<String, dynamic> _AccountToMap(Account acc) {
  return {
    fldName: acc.name,
    fldType: acc.type.id,
    fldInitlaBalance: acc.initialBalance,
    fldCreated: acc.created.millisecondsSinceEpoch,
    fldCurrency: acc.currency,
    fldBalance: acc.balance,
    fldSpent: acc.spent,
    fldEarn: acc.earn};
}

Account _snapshotToAccount(DocumentSnapshot snapshot) {
  var initialBalance = snapshot.data[fldInitlaBalance];
  var created = snapshot.data[fldCreated];

  return Account
    (_toId(snapshot),
    snapshot.data[fldName],
    double.parse("${initialBalance == null ? '0' : initialBalance}"),
    snapshot.data[fldType] == null ? null : AccountType.all[snapshot.data[fldType]],
    snapshot.data[fldCurrency],
    created: created == null ? null : DateTime.fromMillisecondsSinceEpoch(created),);
}

Map<String, dynamic> _CategoryToMap(AppCategory cat) {
  return {fldName: cat.name, fldColorHex: cat.colorHex, };
}

Map<String, dynamic> _UserToMap(User user, {int color}) {
  return {fldUuid: user.uuid, fldEmail: user.email, fldDisplayName: user.displayName, fldPhotoUrl: user.photoUrl, fldColor: color != null ? color : user.color};
}

Map<String, dynamic> _BudgetToMap(Budget budget) {
  return {
    fldCategoryId: budget.categoryId,
    fldAmount: budget.budgetPerMonth,
    fldStart: budget.budgetStart.millisecondsSinceEpoch,
    fldEnd: budget.budgetEnd != null ? budget.budgetEnd.millisecondsSinceEpoch : null};
}

Budget _snapshotToBudget(DocumentSnapshot snapshot) {
  return Budget(
      _toId(snapshot),
      snapshot.data[fldCategoryId],
      snapshot.data[fldAmount] == null ? null : snapshot.data[fldAmount] * 1.0,
      snapshot.data[fldStart] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldStart]),
      snapshot.data[fldEnd] != null ? DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldEnd]) : null);
}


AppCategory _snapshotToCategory(DocumentSnapshot snapshot) {
  return AppCategory(
      _toId(snapshot),
      snapshot.data[fldName],
      snapshot.data[fldColorHex],
  );
//      snapshot.data[fldBalance] != null ? double.parse("${snapshot.data[fldBalance]}") : null);
}

Map<String, dynamic> _TransactionToMap(AppTransaction trans) {
  return {fldDateTime: trans.dateTime.millisecondsSinceEpoch, fldAccountId: trans.accountId, fldCategoryId: trans.categoryId, fldAmount: trans.amount, fldDesc: trans.desc, fldType: trans.type.id, fldUuid: trans.userUid};
}

AppTransaction _snapshotToTransaction(DocumentSnapshot snapshot) {
  return AppTransaction(
      _toId(snapshot),
      snapshot.data[fldDateTime] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
      snapshot.data[fldAccountId],
      snapshot.data[fldCategoryId],
      snapshot.data[fldAmount] == null ? null : double.parse("${snapshot.data[fldAmount]}"),
      snapshot.data[fldDesc],
      snapshot.data[fldType] == null ? null : TransactionType.all[snapshot.data[fldType]],
      snapshot.data[fldUuid]);
}

Map<String, dynamic> _TransferToMap(Transfer transfer) {
  return {
    fldTransferId: transfer.id,
    fldTransferFrom: transfer.fromAccount,
    fldTransferTo: transfer.toAccount,
    fldAmount: transfer.amount,
    fldDateTime: transfer.transferDate.millisecondsSinceEpoch,
    fldUuid: transfer.userUuid
  };
}

Transfer _snapshotToTransfer(DocumentSnapshot snapshot) {
  return Transfer(
      _toId(snapshot),
      snapshot.data[fldTransferFrom],
      snapshot.data[fldTransferTo],
      snapshot.data[fldAmount],
      snapshot.data[fldDateTime] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
      snapshot.data[fldUuid]
  );
}

Map<String, dynamic> _DischargeOfLiabilityToMap(DischargeOfLiability discharge) {
  return {
    fldDateTime: discharge.dateTime.millisecondsSinceEpoch,
    fldAccountId: discharge.accountId,
    fldLiabilityId: discharge.liabilityId,
    fldCategoryId: discharge.categoryId,
    fldAmount: discharge.amount,
    fldUuid: discharge.userUid
  };
}

DischargeOfLiability _snapshotToDischargeOfLiability(DocumentSnapshot snapshot) {
  return DischargeOfLiability(
    _toId(snapshot),
    snapshot.data[fldDateTime] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(snapshot.data[fldDateTime]),
    snapshot.data[fldLiabilityId],
    snapshot.data[fldAccountId],
    snapshot.data[fldCategoryId],
    snapshot.data[fldAmount],
    snapshot.data[fldUuid]
  );
}

int _toId(DocumentSnapshot snapshot) {
  return int.parse(snapshot.documentID);
}

void _onAccountAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onAccountRemoved(document);

    return;
  }
  db.insertAccount(_snapshotToAccount(document)).catchError((e) => _onAccountChanged(document));
}

void _onAccountChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onAccountRemoved(document);

    return;
  }
    db.updateAccount(_snapshotToAccount(document));
}

void _onAccountRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteAccount(_toId(document));
}

void _onCategoryAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onCategoryRemoved(document);

    return;
  }
  db.insertCagetory(_snapshotToCategory(document)).catchError((e) => _onCategoryChanged(document));
}

void _onCategoryChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onCategoryRemoved(document);

    return;
  }

  db.updateCategory(_snapshotToCategory(document));
}

void _onCategoryRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteCategory(_toId(document));
}

void _onTransactionAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onTransactionRemoved(document);

    return;
  }

  db.insertTransaction(_snapshotToTransaction(document)).catchError((e) => _onTransactionChanged(document));
}

void _onTransactionChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onTransactionRemoved(document);

    return;
  }
  db.updateTransaction(_snapshotToTransaction(document));
}

void _onTransactionRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteTransaction(_toId(document));
}

void _onUserAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onUserRemoved(document);

    return;
  }
  db.insertUser(snapshotToUser(document)).catchError((e) => _onUserChanged(document));
}

void _onUserChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onUserRemoved(document);

    return;
  }
  db.updateUser(snapshotToUser(document));
}

void _onUserRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteUser(document.data[fldUuid]);
}

void _onBudgetAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onBudgetRemoved(document);

    return;
  }
  db.insertBudget(_snapshotToBudget(document)).catchError((e) => _onBudgetChanged(document));
}

void _onBudgetChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) return;
  db.updateBudget(_snapshotToBudget(document));
}

void _onBudgetRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteBudget(_toId(document));
}

void _onTransferAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onTransferRemoved(document);

    return;
  }

  db.insertTransfer(_snapshotToTransfer(document)).catchError((e) => _onTransferChanged(document));
}

void _onTransferChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onTransferRemoved(document);

    return;
  }

  db.updateTransfer(_snapshotToTransfer(document));
}

void _onTransferRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteTransfer(_toId(document));
}

void _onDischargeOfLiabilityAdded(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onDischargeOfLiabilityRemoved(document);

    return;
  }

  db.insertDischargeOfLiability(_snapshotToDischargeOfLiability(document)).catchError((e) => _onDischargeOfLiabilityChanged(document));
}

void _onDischargeOfLiabilityChanged(DocumentSnapshot document) {
  _delaySync();

  if(document.data == null) {
    var id = _toId(document);

    if(id != null) _onDischargeOfLiabilityRemoved(document);

    return;
  }

  db.updateDischargeOfLiability(_snapshotToDischargeOfLiability(document));
}

void _onDischargeOfLiabilityRemoved(DocumentSnapshot document) {
  _delaySync();

  db.deleteDischargeOfLiability(_toId(document));

}
// ####################################################################################################
// Account
Lock _lock = Lock();

Future<bool> addAccount(Account acc) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblAccount).document("${acc.id}").setData(_AccountToMap(acc));
    return true;
  });
}

Future<bool> updateAccount(Account acc) async {
  return addAccount(acc);
}

Future<bool> deleteAccount(Account acc) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblAccount).document("${acc.id}").delete();
    return true;
  });
}

// ####################################################################################################
// Transaction
Future<bool> addTransaction(AppTransaction transaction) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblTransaction).document("${transaction.id}").setData(_TransactionToMap(transaction));
    return true;
  });
}

Future<bool> updateTransaction(AppTransaction trans) async {
  return addTransaction(trans);
}

Future<bool> deleteTransaction(AppTransaction trans) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblTransaction).document("${trans.id}").delete();
    return true;
  });
}

Future<bool> deleteAllTransaction(List<AppTransaction> transactions) {
  return _lock.synchronized(() async {
    for(AppTransaction transaction in transactions) {
      await _firestore.collection(tblTransaction).document("${transaction.id}").delete();
    }

    return true;
  });
}

// ####################################################################################################
// Category
Future<bool> addCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblCategory).document("${cat.id}").setData(_CategoryToMap(cat));

    return true;
  });
}

Future<bool> updateCategory(AppCategory cat) {
  return addCategory(cat);
}

Future<bool> deleteCategory(AppCategory cat) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblCategory).document("${cat.id}").delete();

    return true;
  });
}

// ####################################################################################################
// User
Future<bool> addUser(User user, {int color}) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblUser).document(user.uuid).setData(_UserToMap(user, color: color));
    return true;
  });
}

Future<bool> updateUser(User user) {
  return addUser(user);
}

Future<bool> deleteUser(User user) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblUser).document(user.uuid).delete();
    return true;
  });
}

// ####################################################################################################
// Budget
Future<bool> addBudget(Budget budget) async {
  return _lock.synchronized(() async {
    _firestore.collection(tblBudget).document("${budget.id}").setData(_BudgetToMap(budget));
    return true;
  });
}

Future<bool> updateBudget(Budget budget) {
  return addBudget(budget);
}

Future<bool> deleteBudget(int id) async {
  return _lock.synchronized(() async {
    await _firestore.collection(tblBudget).document("$id").delete();
    return true;
  });
}

// ####################################################################################################
// Transfer

Future<bool> addTransfer(Transfer transfer) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblTransfer).document("${transfer.id}").setData(_TransferToMap(transfer));
    return true;
  });
}

Future<bool> updateTransfer(Transfer transfer) {
  return addTransfer(transfer);
}

Future<bool> deleteAllTransfer(List<Transfer> transfers) {
  return _lock.synchronized(() async {
    for(Transfer transfer in transfers) {
      await _firestore.collection(tblTransfer).document("${transfer.id}").delete();
    }

    return true;
  });
}

// ####################################################################################################
// Transfer

Future<bool> addDischargeOfLiability(DischargeOfLiability discharge) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblDischargeOfLiability).document("${discharge.id}").setData(_DischargeOfLiabilityToMap(discharge));
    return true;
  });
}

Future<bool> update(DischargeOfLiability discharge) {
  return addDischargeOfLiability(discharge);
}

Future<bool> deleteDischargeOfLiability(DischargeOfLiability discharge) {
  return _lock.synchronized(() async {
    await _firestore.collection(tblDischargeOfLiability).document("${discharge.id}").delete();
  });
}

// ####################################################################################################
// other reference task
Future<bool> removeReference() async {
  return _lock.synchronized(() async {
    _unsubscribe();
    _isDbSetup = false;
  });
}

void _unsubscribe() {
  if(subs != null) subs.forEach((key, value) async {
    await value.cancel();
  });

  subs = {};
}



