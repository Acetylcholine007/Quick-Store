import 'package:flutter/material.dart';
import 'package:quick_store/components/FieldLabel.dart';
import 'package:quick_store/models/Account.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';
import 'package:quick_store/shared/decorations.dart';
import 'package:uuid/uuid.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';

  void signupHandler() async {
    if (_formKey.currentState.validate()) {
      var uuid = Uuid();
      String result = await LocalDatabaseService.db.signup(Account(
        uid: uuid.v1(),
        username: username,
      ));
      if (result == 'SUCCESS') {
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Sign Up'),
              content: Text(result),
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
                        Text('SIGN-UP', style: theme.textTheme.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
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
                        SizedBox(height: 50),
                        ElevatedButton(onPressed: signupHandler, child: Text('SIGN UP'), style: formButtonDecoration)
                      ],
                    ),
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
