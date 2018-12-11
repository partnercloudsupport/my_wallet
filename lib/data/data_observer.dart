import 'package:my_wallet/data/database_manager.dart' as db;

const tableAccount = "table_accounts";
const tableTransactions = "table_transactions";
const tableCategory = "table_categories";
const tableBudget = "table_budget";

abstract class DatabaseObservable {
  void onDatabaseUpdate(String table);
}

void registerDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.registerDatabaseObservable(tables, observable);
}

void unregisterDatabaseObservable(List<String> tables, DatabaseObservable observable) {
  db.unregisterDatabaseObservable(tables, observable);
}


