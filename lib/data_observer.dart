import 'package:my_wallet/database/database_manager.dart' as db;

const tableAccount = "table_accounts";
const tableTransactions = "table_transactions";
const tableCategory = "table_categories";
const tableBudget = "table_budget";

abstract class DatabaseObservable {
  void onDatabaseUpdate();
}

void registerDatabaseObservable(String table, DatabaseObservable observable) {
  db.registerDatabaseObservable(table, observable);
}

void unregisterDatabaseObservable(String table, DatabaseObservable observable) {
  db.unregisterDatabaseObservable(table, observable);
}


