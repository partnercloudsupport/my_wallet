import 'package:my_wallet/ui/user/login/presentation/view/login_data_view.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/login/presentation/presenter/login_presenter.dart';
import 'package:my_wallet/font/my_flutter_app_icons.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends CleanArchitectureView<Login, LoginPresenter> implements LoginDataView {
  _LoginState() : super(LoginPresenter());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<RoundedButtonState> _loginKey = GlobalKey();
  final GlobalKey<RoundedButtonState> _googleKey = GlobalKey();
  final GlobalKey<RoundedButtonState> _facebookKey = GlobalKey();

  bool _obscureText = true;

  bool _signingIn = false;
  @override
  void init() {
    presenter.dataView = this;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image.asset("assets/nartus.png"),
//          Text(
//            "Login with your social account",
//            style: Theme.of(context).textTheme.title,
//          ),
//          Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              mainAxisSize: MainAxisSize.max,
//              children: <Widget>[
//                Expanded(
//                  child: RoundedButton(
//                    key: _facebookKey,
//                    onPressed: _onFacebookButtonPressed,
//                    padding: EdgeInsets.all(10.0),
//                    child: Icon(
//                      MyFlutterApp.facebook_rect,
//                      color: AppTheme.white,
//                    ),
//                    radius: 5.0,
//                    color: AppTheme.facebookColor,
//                  ),
//                ),
//                Expanded(
//                  child: RoundedButton(
//                    key: _googleKey,
//                    onPressed: _onGoogleButtonPressed,
//                    padding: EdgeInsets.all(10.0),
//                    child: Icon(
//                      MyFlutterApp.googleplus_rect,
//                      color: AppTheme.white,
//                    ),
//                    radius: 5.0,
//                    color: AppTheme.googleColor,
//                  ),
//                ),
//              ],
//          ),
//          Padding(
//              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
//              child: Row(
//                children: <Widget>[
//                  Expanded(
//                    child: Container(
//                      height: 1.0,
//                      color: AppTheme.white,
//                    ),
//                  ),
//                  Padding(
//                    padding: EdgeInsets.all(5.0),
//                    child: Text(
//                      "OR",
//                      style: Theme.of(context).textTheme.title,
//                    ),
//                  ),
//                  Expanded(
//                    child: Container(
//                      height: 1.0,
//                      color: AppTheme.white,
//                    ),
//                  )
//                ],
//              ),
//            ),
//          Text(
//            "Login with your email",
//            style: Theme.of(context).textTheme.title,
//          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email Address",
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye, color: _obscureText ? AppTheme.white : AppTheme.blueGrey,), onPressed: () => setState(() => _obscureText = !_obscureText))
                ),
                keyboardType: TextInputType.text,
                obscureText: _obscureText,
              )
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RoundedButton(
                key: _loginKey,
                onPressed: _signIn,
                child: Padding(padding: EdgeInsets.all(12.0), child: Text("Sign In", style: TextStyle(color: AppTheme.white),),),
                color: AppTheme.blue,
              ),
              RoundedButton(
                onPressed: _register,
                child: Padding(padding: EdgeInsets.all(12.0), child: Text("Register your email", style: TextStyle(color: AppTheme.darkBlue),),),
                color: AppTheme.white,
              )
            ],),
        ],
      ),),
    );
  }

  void _signIn() {
    if (_signingIn) return;

    _signingIn = true;
    _loginKey.currentState.process();

    presenter.signIn(_emailController.text, _passwordController.text);
  }

  @override
  void onSignInSuccess(bool hasDisplayName) {
    presenter.checkUserHome();
  }

  @override
  void onSignInFailed(Exception e) {
    stopProcessing();

    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Sign in failed"),
      content: Text("Sign in to email ${_emailController.text} failed with error ${e.toString()}"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Try Again"),
        )
      ],
    )
    );
  }

  void onUserHomeResult(bool exist) {
    stopProcessing();

    Navigator.pushReplacementNamed(context, exist ? routes.MyHome : routes.HomeProfile);
  }

  void onUserHomeFailed(Exception e) {
    stopProcessing();

    print(e.toString());

    onUserHomeResult(true);
  }

  void _register() {
    Navigator.pushNamed(context, routes.Register);
  }

  void _onFacebookButtonPressed() {
    print("Facebook authentication");
    if(_signingIn) return;

    _signingIn = true;
    _facebookKey.currentState.process();
    presenter.signInWithFacebook();
  }

  void _onGoogleButtonPressed() {
    print("Google Authentication");
    if(_signingIn) return;

    _signingIn = true;
    _googleKey.currentState.process();
    presenter.signInWithGoogle();
  }

  void stopProcessing() {
    _signingIn = false;

    if(_loginKey.currentState != null) _loginKey.currentState.stop();
    if(_googleKey.currentState != null) _googleKey.currentState.stop();
    if(_facebookKey.currentState != null) _facebookKey.currentState.stop();

  }
}