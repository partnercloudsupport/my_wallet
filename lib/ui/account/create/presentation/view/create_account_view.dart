import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/create/presentation/presenter/create_account_presenter.dart';
import 'package:my_wallet/ui/account/create/presentation/view/create_account_dataview.dart';

import 'package:intl/intl.dart';

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends CleanArchitectureView<CreateAccount, CreateAccountPresenter> implements CreateAccountDataView {
  _CreateAccountState() : super(CreateAccountPresenter());

  final GlobalKey<NumberInputPadState> _numPadKey = GlobalKey();

  final _nf = NumberFormat("\$#,##0.00");

  AccountType _type = AccountType.paymentAccount;
  String _name = "";
  double _amount = 0.0;

  init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    var appBar = MyWalletAppBar(
      title: "Create Account",
      actions: <Widget>[
        FlatButton(
          child: Text("Save"),
          onPressed: _saveAccount,
        )
      ],
    );

    return GradientScaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.center,
              color: AppTheme.white,
              child: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ConversationRow(
                        "Create new",
                        _type.name,
                        dataColor: AppTheme.darkBlue,
                        onPressed: _showAccountTypeSelection),
                    ConversationRow(
                      "with name",
                      _name == null || _name.isEmpty ? "Enter a name" : _name,
                      dataColor: AppTheme.darkBlue,
                      onPressed: _showAccountNameDialog,),
                    ConversationRow(
                      "and intial amount",
                      _nf.format(_amount),
                      dataColor: AppTheme.brightPink,
                      style: Theme.of(context).textTheme.display2,),
                  ],
                ),
              ),
            ),
          ),
          Align(
            child: NumberInputPad(_numPadKey, _onNumberInput, null, null, showNumPad: true,),
            alignment: Alignment.bottomCenter,
          )
        ],
      )
    );
  }

  void _showAccountTypeSelection() {
    _numPadKey.currentState.hide();
    showModalBottomSheet(context: context, builder: (context) =>
        BottomViewContent(
            AccountType.all, (f) =>
            Align(
              child: InkWell(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(f.name, style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue))
                ),
                onTap: () {
                  setState(() => _type = f);

                  _numPadKey.currentState.show();

                  Navigator.pop(context);
                },
              ),
              alignment: Alignment.center,
            )
        )
    );
  }

  void _showAccountNameDialog() {
    Navigator.push(context, SlidePageRoute(builder: (context) => InputName("Account Name",(name) => setState(() => _name = name), hintText: "Enter Account Name",)));
  }

  void _onNumberInput(double amount) {
    setState(() => _amount = amount);
  }

  void _saveAccount() {
    presenter.saveAccount(_type, _name, _amount);
  }

  void onAccountSaved(bool result) {
    if(result) Navigator.pop(context, result);
  }

  void onError(Exception e) {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(e.toString()),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ));  }
}