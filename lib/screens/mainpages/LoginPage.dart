import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quick_store/components/FieldLabel.dart';
import 'package:quick_store/models/LoginResponse.dart';
import 'package:quick_store/screens/mainpages/SignupPage.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';
import 'package:quick_store/shared/decorations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final Function setAccount;
  const LoginPage({Key key, this.setAccount}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';

  void loginHandler() async {
    if (_formKey.currentState.validate()) {
      LoginResponse response = await LocalDatabaseService.db.login(username);
      if(response.account != null && response.message == 'SUCCESS') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', response.account.username);
        widget.setAccount(response.account);
      } else {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: Text('Login'),
                  content: Text(response.message),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        child: Text('OK')
                    )
                  ],
                )
        );
      }
    } else {
      final snackBar = SnackBar(
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        content: Text('Fill up all the fields'),
        action: SnackBarAction(label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: theme.primaryColorDark, //change your color here
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset('assets/images/appLogo.png', width: 150, height: 150),
                        Text('LOG IN', style: theme.textTheme.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                        SizedBox(height: 50),
                        FieldLabel(
                          label: 'USERNAME',
                          child: TextFormField(
                              initialValue: username,
                              decoration:
                              formFieldDecoration.copyWith(hintText: 'Username'),
                              validator: (val) => val.isEmpty ? 'Enter Username' : null,
                              onChanged: (val) => setState(() => username = val)
                          ),
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(onPressed: loginHandler, child: Text('LOG IN'), style: formButtonDecoration)
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      text: 'DO NOT HAVE AN ACCOUNT? ',
                      style: theme.textTheme.bodyText1,
                      children: [
                        TextSpan(
                          text: 'SIGN UP HERE',
                          style: theme.textTheme.bodyText1.copyWith(color: theme.primaryColorDark, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                            }),
                          ]
                        )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
