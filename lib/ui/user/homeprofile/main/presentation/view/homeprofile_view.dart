import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/homeprofile/main/presentation/presenter/homeprofile_presenter.dart';
import 'package:my_wallet/ui/user/homeprofile/main/presentation/view/homeprofile_data_view.dart';

import 'package:my_wallet/ui/user/homeprofile/newhome/presentation/view/newhome_view.dart';

class HomeProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeProfileState();
  }
}

class _HomeProfileState extends CleanArchitectureView<HomeProfile, HomeProfilePresenter> implements HomeProfileDataView {

  _HomeProfileState() : super(HomeProfilePresenter());

  HomeEntity _homeEntity;
  bool _checking = true;

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.findUserHome();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: MyWalletAppBar(
        title: "Set up your home profile",
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppTheme.white
        ),
        padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(20.0),
          child: _checking ? Center(child: CircularProgressIndicator(),)
              : _homeEntity == null ? NewHome() : _confirmHome()
      ),
    );
  }

  Widget _confirmHome() {
    return Center(child:  Text("Nothing yet", style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),),);
  }

  void onHomeResult(HomeEntity entity) {
    setState(() {
      _checking = false;
      _homeEntity = entity;
    });
  }

}