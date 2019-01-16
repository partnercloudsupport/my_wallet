import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/about/presentation/presenter/about_presenter.dart';
import 'package:my_wallet/ui/about/presentation/view/about_data_view.dart';

import 'package:my_wallet/app_material.dart';


class AboutUs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutUsState();
  }
}

class _AboutUsState extends CleanArchitectureView<AboutUs, AboutUsPresenter> implements AboutUsDataView {

  _AboutUsState() : super(AboutUsPresenter());

  String _version = "";
  List<TextSpan> _aboutText = [];

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: "About",
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset("assets/nartus.png"),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(8.0),
            child: Text("App Version $_version", style: Theme.of(context).textTheme.body1.apply(color: AppTheme.darkBlue),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: _aboutText
              ),
            ),
          ),
        ],
      )
    );
  }


  @override
  void updateDetail(AboutEntity entity) {
    setState(() {
      TextStyle style = Theme.of(context).textTheme.body1;
      _version = entity.version;
      _aboutText = entity.aboutUs.map((f) {
        switch(f.type) {
          case TextType.emphasized: return TextSpan(text: f.text, style: style.apply(fontWeightDelta: 2, color: AppTheme.pinkAccent));
          case TextType.normal: return TextSpan(text: f.text, style: style.apply(color: AppTheme.black));
        }
      }).toList();
    });
  }
}