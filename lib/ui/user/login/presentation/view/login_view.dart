import 'package:my_wallet/ui/user/login/presentation/view/login_data_view.dart';
import 'package:my_wallet/ca/presentation/view/ca_state.dart';
import 'package:my_wallet/ui/user/login/presentation/presenter/login_presenter.dart';
import 'package:my_wallet/ui/home/home_view.dart';

import 'package:my_wallet/ui/user/register/presentation/view/register_view.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlutterLogo(
            size: 150.0,
            curve: Curves.bounceInOut,
          ),
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
                onPressed: _signIn,
                child: Padding(padding: EdgeInsets.all(12.0), child: _signingIn ? SizedBox(
                  width: 15.0,
                  height: 15.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ) : Text("Sign In", style: TextStyle(color: AppTheme.white),),),
                color: AppTheme.blue,
              ),
              RoundedButton(
                onPressed: _register,
                child: Padding(padding: EdgeInsets.all(12.0), child: Text("Register new account", style: TextStyle(color: AppTheme.darkBlue),),),
                color: AppTheme.white,
              )
            ],),
        ],
      ),),
    );
  }

  void _signIn() {
    if (_signingIn) return;

    setState(() => _signingIn = true);
    presenter.signIn(_emailController.text, _passwordController.text);
  }

  @override
  void onSignInSuccess(bool result) {
    setState(() => _signingIn = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyWalletHome()));
  }

  @override
  void onSignInFailed(Exception e) {
    setState(() => _signingIn = false);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Sign in failed"),
      content: Text("Sign in to email ${_emailController.text} failed with error ${e.toString()}"),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Retry"),
        )
      ],
    )
    );
  }

  void _register() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Register()));
  }
}