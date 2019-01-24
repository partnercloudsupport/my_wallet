import 'package:my_wallet/ui/category/create/presentation/presenter/create_category_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_data_view.dart';

class CreateCategory extends StatefulWidget {
  final int id;
  final String name;

  CreateCategory({this.id, this.name});

  @override
  State<StatefulWidget> createState() {
    return _CreateCategoryState();
  }
}

class _CreateCategoryState extends CleanArchitectureView<CreateCategory, CreateCategoryPresenter> implements CreateCategoryDataView {
  _CreateCategoryState() : super(CreateCategoryPresenter());

  String _name;
  CategoryType _type;

  GlobalKey<TransactionTypeState<CategoryType>> _categoryTypeKey = GlobalKey();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    _type = CategoryType.expense;
    _name = widget.name;

    if(widget.id != null) {
      presenter.loadCategoryDetail(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: "Create Category",
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            onPressed: () => presenter.saveCategory(widget.id, _name, _type),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: SelectTransactionType<CategoryType>(
                CategoryType.all,
                _type,
                    (CategoryType data) => data.id,
                    (CategoryType data) => data.name,
                    (CategoryType selected) {
                  _type = selected;
                },
                key: _categoryTypeKey,),
          ),
          DataRowView(
            "Category Name",
            _name == null ? "Enter category name" : _name,
            onPress: () => Navigator.push(context, SlidePageRoute(builder: (context) => InputName("Category Name", _onNameChanged, hintText: _name == null ? "Enter category name" : _name))),
          ),
        ],
      ),
    );
  }

  @override
  void onCreateCategorySuccess(int categoryId) {
    Navigator.pop(context, categoryId);
  }

  @override
  void onCreateCategoryError(Exception e) {
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Error"),
      content: Text(e.toString()),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        )
      ],
    ));
  }

  @override
  void onCategoryDetailLoaded(AppCategory category) {
    setState(() {
      _name = category.name;
      _type = category.categoryType;

      if(_categoryTypeKey.currentContext != null) {
        _categoryTypeKey.currentState.updateSelection(_type);
      }
    });

    debugPrint("category loaded $_name ${_type.name}");
  }

  void _onNameChanged(String name) {
    _name = name;
  }
}