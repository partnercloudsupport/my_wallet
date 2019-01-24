import 'package:my_wallet/data/data.dart';

import 'package:my_wallet/ui/category/list/presentation/presenter/list_category_presenter.dart';

import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/category/list/presentation/view/list_category_data_view.dart';

import 'package:my_wallet/data/data_observer.dart' as observer;
import 'package:intl/intl.dart';

class CategoryList extends StatefulWidget {
  final String _title;
  final bool returnValue;

  CategoryList(this._title, {this.returnValue = false});

  @override
  State<StatefulWidget> createState() {
    return _CategoryListState();
  }
}

class _CategoryListState extends CleanArchitectureView<CategoryList, ListCategoryPresenter> implements CategoryListDataView, observer.DatabaseObservable {
  _CategoryListState() : super(ListCategoryPresenter());

  final tables = [observer.tableCategory];
  final _nf = NumberFormat("\$#,###.##");

  List<CategoryListItemEntity> _categories = [];

  var isEditMode = false;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    observer.registerDatabaseObservable(tables, this);
    _loadCategories();
  }

  @override
  void dispose() {
    observer.unregisterDatabaseObservable(tables, this);
    super.dispose();
  }

  @override
  void onDatabaseUpdate(String table) {
    presenter.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: widget._title,
        actions: <Widget>[
          FlatButton(
            child: Text(isEditMode ? "Done" : "Edit"),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          )
        ],
      ),
      body: Padding(
          padding: EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (_, index) => CardListTile(
                  title: _categories[index].name,
                  trailing: isEditMode ? IconButton(
                    icon: Icon(Icons.close, color: AppTheme.pinkAccent,),
                    onPressed: () {
                      presenter.deleteCategory(_categories[index].categoryId);
                    }) :
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("${_nf.format(_categories[index].spent)}"),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkBlue,
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border.all(color: AppTheme.lightBlue, width: 1.0)
                    ),
                    margin: EdgeInsets.only(top: 5.0),
                    padding: EdgeInsets.only(left: 4.0, right: 4.0),
                    child: Text("${_nf.format(_categories[index].budget)}"),
                  )
                ],
              ),
                  onTap: () => widget.returnValue
                      ? Navigator.pop(context, _categories[index])
                      : isEditMode ? Navigator.pushNamed(context, routes.EditCategory(categoryId: _categories[index].categoryId, categoryName: _categories[index].name))
                      : Navigator.pushNamed(
                      context,
                      routes.TransactionList(_categories[index].name, categoryId: _categories[index].categoryId)
                  ),
                ),
          )),
      floatingActionButton: isEditMode
          ? RoundedButton(
              onPressed: () => Navigator.pushNamed(context, routes.CreateCategory).then((value) {
                    if (value != null) _loadCategories();
                  }),
              child: Text(
                ("Create Category"),
              ),
              color: AppTheme.pinkAccent,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _loadCategories() {
    presenter.loadCategories();
  }

  void onCategoriesLoaded(List<CategoryListItemEntity> value) {
    if (value != null)
      setState(() {
        _categories = value;
      });
  }

  int stageCrossAxisCellCount(String name) {
    if (name.length > 12)
      return 3;
    else if (name.length > 7)
      return 2;
    else
      return 1;
  }

  int stageMainAxisCellCount(String name) {
    return 1;
  }
}
