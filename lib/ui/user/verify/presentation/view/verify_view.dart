import 'package:my_wallet/ca/presentation/view/ca_state.dart';

import 'package:my_wallet/ui/user/verify/presentation/view/verify_data_view.dart';
import 'package:my_wallet/ui/user/verify/presentation/presenter/verify_presenter.dart';

class RequestValidation extends StatefulWidget {
  final bool isProcessing;

  RequestValidation({this.isProcessing = false});

  @override
  State<StatefulWidget> createState() {
    return _RequestValidationState();
  }
}

class _RequestValidationState extends CleanArchitectureView<RequestValidation, RequestValidationPresenter> implements RequestValidationDataView {
  _RequestValidationState() : super(RequestValidationPresenter());

  GlobalKey<RoundedButtonState> _resendKey = GlobalKey();
  GlobalKey<RoundedButtonState> _revalidateKey = GlobalKey();

  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return PlainScaffold(
      appBar: MyWalletAppBar(
        title: "Validate account",
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        child: widget.isProcessing ? _buildProcessingPage() : _buildRequestPage()
      ),
    );
  }

  Widget _buildRequestPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Please click on the link sent to your email to validate your account. To request new validation email, click the button below",
          style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
          textAlign: TextAlign.center,
        ),
        RoundedButton(
          key: _resendKey,
          onPressed: _requestValidationEmail,
          child: Text("Send new validation email"),
          color: AppTheme.darkBlue,
        ),
        RoundedButton(
          onPressed: _changeEmail,
          child: Text("Change email address"),
          color: AppTheme.blueGrey,
        )
      ],
    );
  }

  Widget _buildProcessingPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "An email is sent to your email address. Please click on the link in that email to validate your account. Click below button after you have validated your email",
          style: Theme.of(context).textTheme.title.apply(color: AppTheme.darkBlue),
          textAlign: TextAlign.center,
        ),
        RoundedButton(
          key: _revalidateKey,
          onPressed: _checkUserValidation,
          child: Text("Validated"),
          color: AppTheme.darkBlue,
        ),
      ],
    );
  }

  void _requestValidationEmail() {
    if(_resendKey.currentContext != null) _resendKey.currentState.process();

    presenter.requestValidationEmail();
  }

  @override
  void onRequestSent(bool result) {
    // show waiting for validation page
    Navigator.pushReplacementNamed(context, routes.ValidationProcessing);
  }

  void _changeEmail() {
    presenter.signOut();
  }

  @override
  void onSignOutSuccess(bool result) {
    Navigator.pushReplacementNamed(context, routes.Login);
  }

  void _checkUserValidation() {
    if(_revalidateKey.currentContext != null) _revalidateKey.currentState.process();
    print("_checkUserValidation");
    presenter.checkUserValidation();
  }

  @override
  void onValidationResult(bool validated) {
    if(validated) Navigator.pushReplacementNamed(context, routes.HomeProfile);
    else Navigator.pushReplacementNamed(context, routes.RequestValidation);
  }
}