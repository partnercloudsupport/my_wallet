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

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return InputName("Create Category", _onNameChanged, hintText: "Category Name", autoDismiss: false);
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


  void _onNameChanged(String name) {
    presenter.saveCategory(name);
  }
}