import 'package:flutter/material.dart';
import 'package:my_wallet/my_wallet_view.dart';
import 'package:my_wallet/database/data.dart';
import 'package:my_wallet/app_theme.dart' as theme;
import 'package:intl/intl.dart';

import 'package:my_wallet/ui/account/create/presentation/presenter/create_account_presenter.dart';

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

enum _CreateAccountSteps {
  SelectAccountType,
  EnterDetail
}

class _CreateAccountState extends State<CreateAccount> {
  final CreateAccountPresenter _presenter = CreateAccountPresenter();

  String title = "Select Account Type";

  PageController _pageController = PageController(initialPage: _CreateAccountSteps.SelectAccountType.index);

  AccountType _type = AccountType.paymentAccount;
  String _name = "";

  GlobalKey<_EnterDetailState> _detailState = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool showNumberInputPad = false;

  @override
  void dispose() {
    super.dispose();

    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MyWalletAppBar(
        title: title,
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            onPressed: _saveAccount,
          )
        ],
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.darkBlue,
                theme.darkBlue.withOpacity(0.9),
              ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
          ),
    child: PageView.builder(
        physics:new NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: _CreateAccountSteps.values.length,
        itemBuilder: _createAccountPage)
      ),
    );
  }

  Widget _createAccountPage(BuildContext context, int index) {
    _CreateAccountSteps step = _CreateAccountSteps.values[index];

    switch(step) {
      case _CreateAccountSteps.SelectAccountType: return _SelectAccountType(_onAccountSelected);
      default: return _EnterDetail(_detailState, _type, _onAccountChangeRequest);
    }
  }

  void _onAccountChangeRequest() {
    _pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  void _onAccountSelected(AccountType type) {
    _type = type;
    if(_detailState != null && _detailState.currentState != null) _detailState.currentState.setType(_type);

    _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease)
    .then((_) {
      setState(() {
        title = "Enter Account Detail";
      });
    });
  }

  void _saveAccount() {
    _presenter.saveAccount(_type, _name, _detailState.currentState._getAmount())
    .then((result) {
      Navigator.pop(context, result);
//    })
//    .catchError((e) {
//      showDialog(context: context, builder: (context) => AlertDialog(
//        title: Text("Error"),
//        content: Text(e.toString()),
//        actions: <Widget>[
//          FlatButton(
//            onPressed: () => Navigator.pop(context),
//            child: Text("OK"),
//          )
//        ],
//      ));
    });
  }
}

class _SelectAccountType extends StatelessWidget {
  final ValueChanged<AccountType> _onAccountSelected;

  _SelectAccountType(this._onAccountSelected);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView(
            shrinkWrap: true,
            children: AccountType.all.map((f) => InkWell(
              child: Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Text(f.name, style: Theme.of(context).textTheme.headline.apply(color: Colors.white),),
              ),
              onTap: () => _onAccountSelected(f),
            ),).toList()
        ),
    );
  }
}

class _EnterDetail extends StatefulWidget {
  final AccountType _type;
  final VoidCallback _onAccountChangeRequest;

  _EnterDetail(key, this._type, this._onAccountChangeRequest) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _EnterDetailState();
  }
}

class _EnterDetailState extends State<_EnterDetail> {
  AccountType _type;
  String _name;

  TextEditingController _nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _type = widget._type;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _accountType(),
        _accountName(),
        _initialAmount(),
      ],
    );
  }

  Widget _accountType() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text("Your new account is type", style: Theme.of(context).textTheme.subhead.apply(color: Colors.white.withOpacity(0.9)),),
          FlatButton(
            child: Text(_type.name, style: Theme.of(context).textTheme.headline.apply(color: Colors.white),),
            onPressed: widget._onAccountChangeRequest,
          )
        ],
      ),
    );
  }

  Widget _initialAmount() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.0),
      child: Text("\$0.0", style: Theme.of(context).textTheme.display2),
    );
  }

  Widget _accountName() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text("with name", style: Theme.of(context).textTheme.subhead.apply(color: Colors.white.withOpacity(0.9)),),
          FlatButton(
            child: Text(_name == null || _name.isEmpty ? "Account name" : _name, style: Theme.of(context).textTheme.headline.apply(color: Colors.white),),
            onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Enter your account name", style: Theme.of(context).textTheme.title.apply(color: Colors.white),),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  content: TextField(
                    controller: _nameTextController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.tealAccent)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.tealAccent)),
                      border: UnderlineInputBorder(borderSide: BorderSide(color: theme.tealAccent))
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.5)),),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text("Choose this name"),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _name = _nameTextController.text;
                        });
                      },
                    )
                  ],
                )
            ),
          )
        ],
      ),
    );
  }

  void setType(AccountType type) {
    setState(() {
      _type = type;
    });
  }

  double _getAmount() {
    return 0.0;
  }
}

//class _AccountInitialAmount extends StatefulWidget {
//  final Function _onTap;
//
//  _AccountInitialAmount(key, this._onTap) : super(key: key);
//
//  @override
//  State<StatefulWidget> createState() {
//    return _AccountInitialAmountState();
//  }
//}
//
//class _AccountInitialAmountState extends State<_AccountInitialAmount> {
//  NumberFormat _nf = NumberFormat("#,##0.00");
//  String _number;
//  String _decimal;
//
//  @override
//  Widget build(BuildContext context) {
//    return ListTile(
//      title: Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: <Widget>[
//          Text("Initial Amount"),
//          InkWell(
//            child: Text(formatAmount(_number, _decimal), style: Theme.of(context).textTheme.title.apply(color: theme.darkBlue, fontSizeFactor: 1.5 ),),
//            onTap: widget._onTap,
//          )
//        ],
//      ),
//    );
//  }
//
//  String formatAmount(String number, String decimal) {
//    return "\$${_nf.format(_toNumber(number, decimal))}";
//  }
//
//  double _toNumber(String number, String decimal) {
//    return double.parse("${number == null || number.isEmpty ? "0" : number}.${decimal == null || decimal.isEmpty ? "0" : decimal}");
//  }
//
//  double _getAmount() {
//    return _toNumber(_number, _decimal);
//  }
//
//  void update(String number, String decimal) {
//    setState(() {
//      _number = number == null ? "" : number;
//      _decimal = decimal == null ? "" : decimal;
//    });
//  }
//}