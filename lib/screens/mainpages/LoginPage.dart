import 'package:flutter/material.dart';
import 'package:quick_store/components/FieldLabel.dart';
import 'package:quick_store/models/LoginResponse.dart';
import 'package:quick_store/screens/mainpages/SignupPage.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';
import 'package:quick_store/shared/decorations.dart';

class LoginPage extends StatefulWidget {
  final Function setAccount;
  const LoginPage({Key key, this.setAccount}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool hidePassword = true;

  void loginHandler() async {
    if (_formKey.currentState.validate()) {
      LoginResponse response = await LocalDatabaseService.db.login(username, password);
      if(response.account != null && response.message == 'SUCCESS') {
        // Navigator.pop(context);
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('LOG IN'),
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
                      FieldLabel(
                        label: 'PASSWORD',
                        child: TextFormField(
                          initialValue: password,
                          decoration:
                          formFieldDecoration.copyWith(
                            hintText: 'Password',
                            suffixIcon: IconButton(
                                onPressed: () => setState(() => hidePassword = !hidePassword),
                                icon: Icon(Icons.visibility)
                            )
                          ),
                          validator: (val) => val.isEmpty ? 'Enter Password' : null,
                          onChanged: (val) => setState(() => password = val),
                          obscureText: hidePassword,
                        ),
                      ),
                      ElevatedButton(onPressed: loginHandler, child: Text('LOG IN'))
                    ],
                  ),
                ),
                TextButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                }, child: Text('DO NOT HAVE AN ACCOUNT? SIGN UP HERE'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
