import 'package:flutter/material.dart';

import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:my_wallet/routes.dart' as routes;

import 'package:my_wallet/ui/category/list/presentation/presenter/list_category_presenter.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryList extends StatefulWidget {
  final String _title;
  final TransactionType _type;

  CategoryList(this._title, this._type);

  @override
  State<StatefulWidget> createState() {
    return _CategoryListState();
  }
}

class _CategoryListState extends State<CategoryList> {
  final ListCategoryPresenter _presenter = ListCategoryPresenter();
  List<AppCategory> _categories = [];

  var isEditMode = false;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        itemCount: _categories.length,
        itemBuilder: (context, index) => _buildCategoryView(_categories[index]),
        staggeredTileBuilder: (index) => StaggeredTile.count(index > 0 && index % 2 == 0 ? 2 : 1, index > 0 && index % 4 == 0 ? 2 : 1),
      ),
        floatingActionButton: isEditMode ? RaisedButton(onPressed: () => Navigator.pushNamed(context, routes.CreateCategory)
            .then((value) {
          if(value != null) _loadCategories();
        }),
          child: Text(("Create Category"),),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          color: theme.pinkAccent,) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCategoryView(AppCategory category) {
    Color color = Color(theme.hexToInt(category.colorHex));
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(2.0),
        color: color,
        child: Text(
          "${category.name}",
          style: TextStyle(color: color.withGreen(255).withBlue(200).withRed(100)),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        alignment: Alignment.center,
      ),
      onTap: () => widget._type != null ? Navigator.pop(context, category) : print("${category.name} is tapped") ,
    );
  }

  void _loadCategories() {
    _presenter.loadCategories(widget._type).then((value) {
      if (value != null) {
        setState(() {
          _categories = value;
        });
      }
    });
  }
}
