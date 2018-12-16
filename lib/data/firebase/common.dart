import 'package:my_wallet/data/data.dart';
import 'package:firebase_database/firebase_database.dart';

export 'package:synchronized/synchronized.dart';
export 'package:my_wallet/data/data.dart';
export 'package:flutter/services.dart';

const tblAccount = "Account";
const tblTransaction = "Transaction";
const tblCategory = "Category";
const tblUser = "User";
const tblBudget = "Budget";

const fldName = "name";
const fldType = "type";
const fldBalance = "balance";
const fldCurrency = "currency";
const fldTransactionType = "transactionType";
const fldColorHex = "colorHex";
const fldDateTime = "dateTime";
const fldAccountId = "accountId";
const fldCategoryId = "categoryId";
const fldAmount = "amount";
const fldDesc = "desc";
const fldEmail = "email";
const fldDisplayName = "displayName";
const fldPhotoUrl = "photoUrl";
const fldUuid = "uuid";
const fldColor = "color";
const fldStart = "start";
const fldEnd = "end";

User snapshotToUser(DataSnapshot snapshot) {
  return User(snapshot.value[fldUuid], snapshot.value[fldEmail], snapshot.value[fldDisplayName], snapshot.value[fldPhotoUrl], snapshot.value[fldColor]);
}
