import 'package:my_wallet/ui/category/create/presentation/presenter/create_category_presenter.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/category/create/presentation/view/create_category_data_view.dart';

class CreateCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateCategoryState();
  }
}

class _CreateCategoryState extends CleanArchitectureView<CreateCategory, CreateCategoryPresenter> implements CreateCategoryDataView {
  _CreateCategoryState() : super(CreateCategoryPresenter());

  String _name = "";

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyWalletAppBar(
        title: "Create Category",
        actions: <Widget>[
          FlatButton(
            onPressed: _saveCategory,
            child: Text("Save"),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: TextField(
              onChanged: _onNameChanged,
              decoration: InputDecoration(
                hintText: "Category Name",
                hintStyle: Theme.of(context).textTheme.subhead.apply(color: AppTheme.blueGrey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.darkBlue, width: 1.0)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.darkBlue, width: 1.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    presenter.saveCategory(_name);
  }

  @override
  void onCreateCategorySuccess(bool result) {
    Navigator.pop(context, result);
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


  void _onNameChanged(String name) {
    _name = name;
  }
}