import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/account/transfer/presentation/view/transfer_data_view.dart';
import 'package:my_wallet/ui/account/transfer/presentation/presenter/transfer_presenter.dart';

import 'package:my_wallet/app_material.dart';

import 'package:intl/intl.dart';

class AccountTransfer extends StatefulWidget {
  final int id;
  final String name;

  AccountTransfer(this.id, this.name);

  @override
  State<StatefulWidget> createState() {
    return _AccountTransferState();
  }
}

enum _TransferSteps {
  SelectAccount,
  EnterAmount,
  Confirm
}

class _AccountTransferState extends CleanArchitectureView<AccountTransfer, AccountTransferPresenter> implements AccountTransferDataView {
  _AccountTransferState() : super(AccountTransferPresenter());

  List<Account> _accounts = [];
  double _amount;
  Account _toAccount;
  Account _fromAccount;

  final GlobalKey<_SelectAccountState> _selectAccountKey = GlobalKey();
  final GlobalKey<_EnterAmountState> _amountKey = GlobalKey();
  final GlobalKey<_ConfirmState> _confirmKey = GlobalKey();

  final PageController _controller = PageController();

  final Duration _pageAnimationDuration = Duration(milliseconds: 100);

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  void initState() {
    super.initState();

    presenter.loadAccountDetails(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
        appBar: MyWalletAppBar(
          title: "Transfer",
        ),
        body: PageView.builder(
          controller: _controller,
          itemBuilder: (context, index) {
            var step = _TransferSteps.values[index];

            switch (step) {
              case _TransferSteps.SelectAccount:
                return _SelectAccount(_selectAccountKey, _toAccount, _accounts, _onAccountSelected);
              case _TransferSteps.EnterAmount:
                return _EnterAmount(_amountKey, _toAccount, _onAmountUpdate, _onAccountReselect);
              case _TransferSteps.Confirm:
                return _Confirm(_confirmKey, _toAccount, _fromAccount, _amount, _saveTransaction);
            }
          },
          itemCount: _TransferSteps.values.length,
          pageSnapping: true,
          physics: NeverScrollableScrollPhysics(),
        )
    );
  }

  @override
  void onAccountListUpdated(TransferEntity entity) {
    this._accounts = entity.toAccounts;
    this._fromAccount = entity.fromAccount;

    if (_selectAccountKey.currentContext != null) {
      _selectAccountKey.currentState.updateAccountList(this._toAccount, this._accounts);
    }
  }

  @override
  void onAccountListQueryFailed(Exception e) {
    showDialog(context: context,
    builder: (context) => AlertDialog(
      title: Text("Error"),
      content: Text("Failed to query account info."),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    )).then((_) => Navigator.pop(context));
  }

  void _onAccountSelected(Account account) {
    _toAccount = account;
    _controller.animateToPage(1, duration: _pageAnimationDuration, curve: Curves.ease).then((_) {
      if (_amountKey.currentContext != null) {
        _amountKey.currentState.setupToAccount(_toAccount);
      }
    });
  }

  void _onAccountReselect() {
    _controller.animateToPage(0, duration: _pageAnimationDuration, curve: Curves.ease)
        .then((_) {
      presenter.loadAccountDetails(widget.id);
    });
  }

  void _onAmountUpdate(double amount) {
    this._amount = amount;
    _controller.animateToPage(2, duration: _pageAnimationDuration, curve: Curves.ease)
        .then((_) {
      if(_confirmKey.currentContext != null) _confirmKey.currentState.updateDetail(
        _toAccount,
        _fromAccount,
        _amount
      );
    });
  }

  void _saveTransaction() {
    presenter.transferAmount(_fromAccount, _toAccount, _amount);
  }

  @override
  void onAccountTransferSuccess(bool result) {
    Navigator.pop(context);
  }

  @override
  void onAccountTransferFailed(Exception e) {
    showDialog(context: context,
    builder: (context) => AlertDialog(
      title: Text("Error"),
      content: Text("Error while making transfer. Please try again later"),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    )).then((_) => Navigator.pop(context));
  }
}

class _SelectAccount extends StatefulWidget {
  final List<Account> accounts;
  final Account _toAccount;
  final Function(Account account) onAccountSelected;

  _SelectAccount(key, this._toAccount, this.accounts, this.onAccountSelected) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectAccountState();
  }
}

class _SelectAccountState extends State<_SelectAccount> {
  List<Account> _accounts;
  Account _selected;
  final _nf = NumberFormat("\$#,###.##");

  @override
  void initState() {
    super.initState();

    setupAccount(widget._toAccount, widget.accounts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Select Account to transfer to", style: Theme
              .of(context)
              .textTheme
              .title
              .apply(color: AppTheme.darkBlue),),
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: _accounts == null ? 0 : _accounts.length,
            itemBuilder: (context, index) =>
                ListTile(
                  title: Text(_accounts[index].name, style: Theme
                      .of(context)
                      .textTheme
                      .title
                      .apply(color: AppTheme.darkBlue)),
                  subtitle: Text(_nf.format(_accounts[index].balance), style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .apply(color: AppTheme.darkBlue),),
                  onTap: () {
                    setState(() {
                      _selected = _accounts[index];
                    });
                  },
                  trailing: Icon(_selected != null && _selected.id == _accounts[index].id ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppTheme.darkBlue,),
                )
        ),
        Align(
          child: RoundedButton(
            onPressed: () => widget.onAccountSelected(_selected),
            child: Text("Select Account",),
            color: AppTheme.darkBlue,),
        )
      ],
    );
  }

  void updateAccountList(Account toAccount, List<Account> accounts) {
    setState(() {
      setupAccount(toAccount, accounts);
    });
  }

  void setupAccount(Account toAccount, List<Account> accounts) {
    this._accounts = accounts;
    if (toAccount != null) {
      _selected = toAccount;
    }
    else if (_accounts != null && _accounts.isNotEmpty) _selected = _accounts.first;
  }
}

class _EnterAmount extends StatefulWidget {
  final Account toAccount;
  final Function(double amount) onAmountEntered;
  final Function onAccountReselect;

  _EnterAmount(key, this.toAccount, this.onAmountEntered, this.onAccountReselect) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EnterAmountState();
  }
}

class _EnterAmountState extends State<_EnterAmount> {
  Account _toAccount;
  final _nf = NumberFormat("\$#,###.##");
  var _amount = 0.0;

  final GlobalKey<NumberInputPadState> _numberInputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _toAccount = widget.toAccount;
  }

  void setupToAccount(Account toAccount) {
    setState(() => _toAccount = toAccount);
  }

  @override
  Widget build(BuildContext context) {
    var split = _nf.format(_amount).replaceAll("\$", "").split(".");

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            color: AppTheme.white,
            alignment: Alignment.center,
            child: FittedBox(
              child: Column(children: <Widget>[
                ConversationRow(
                  "Transfer to account",
                  _toAccount.name,
                  dataColor: AppTheme.darkBlue,
                  onPressed: widget.onAccountReselect,
                ),
                ConversationRow(
                  "amount",
                  _nf.format(_amount),
                  style: Theme
                      .of(context)
                      .textTheme
                      .display2,
                ),
              ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: RoundedButton(
            child: Text("Confirm"),
            onPressed: () => widget.onAmountEntered(_amount),
            color: AppTheme.darkBlue,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: AppTheme.bgGradient
          ),
          child: NumberInputPad(_numberInputKey, _onNumberInput, split[0], split.length > 2 ? split[1] : null, showNumPad: true,),
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }

  void _onNumberInput(double amount) {
    _amount = amount;

    setState(() {});
  }
}

class _Confirm extends StatefulWidget {
  final Account toAccount;
  final Account fromAccount;
  final double amount;
  final Function saveTransaction;

  _Confirm(key, this.toAccount, this.fromAccount, this.amount, this.saveTransaction) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConfirmState();
  }
}

class _ConfirmState extends State<_Confirm> {
  Account toAccount;
  Account fromAccount;
  double amount;
  final _nf = NumberFormat("\$#,###.##");

  @override
  void initState() {
    super.initState();

    this.toAccount = widget.toAccount;
    this.amount = widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    print("build confirm page $amount ${toAccount == null ? "no toAccount" : toAccount.name} and from ${fromAccount == null ? " no from account" : fromAccount.name}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ConversationRow(
            "Confirm transfer to account",
            toAccount == null ? "" : toAccount.name,
        ),
        ConversationRow(
          "amount",
          _nf.format(amount == null ? 0.0 : amount),
          style: Theme
              .of(context)
              .textTheme
              .display2,
        ),
        ConversationRow(
            "After transfer is done, balance is",
            "",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConversationRow(
                "Account",
                toAccount == null ? "" : toAccount.name,
            ),
            ConversationRow(
              "has",
              _nf.format((toAccount == null ? 0.0 : toAccount.balance) + (amount == null ? 0.0 : amount)),
              style: Theme
                  .of(context)
                  .textTheme
                  .title,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConversationRow(
                "and Account",
                fromAccount == null ? "" : fromAccount.name,
            ),
            ConversationRow(
              "has",
              _nf.format((fromAccount == null ? 0.0 : fromAccount.balance) - (amount == null ? 0.0 : amount)),
              style: Theme
                  .of(context)
                  .textTheme
                  .title,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: RoundedButton(
            child: Text("Confirmed! Transfer Now!"),
            onPressed: widget.saveTransaction,
            color: AppTheme.darkBlue,
          ),
        )
      ],
    );
  }

  void updateDetail(
      Account _toAccount,
      Account _fromAccount,
      double _amount
      ) {
    setState(() {
      this.toAccount = _toAccount;
      this.fromAccount = _fromAccount;
      this.amount = _amount;
    });
  }
}