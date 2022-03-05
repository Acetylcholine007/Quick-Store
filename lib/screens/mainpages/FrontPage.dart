import 'package:flutter/material.dart';
import 'package:quick_store/models/LoginResponse.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';
import 'package:quick_store/wrappers/AuthWrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({Key key}) : super(key: key);

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Color(0xFFF2E7E7),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset('assets/images/appLogo.png', width: 150, height: 150),
                  Text('QUICK STORE', style: theme.textTheme.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                  Text('INVENTORY', style: theme.textTheme.bodyText1.copyWith(color: Color(0xFF459A7C), fontWeight: FontWeight.w700))
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  String username = prefs.getString('username') ?? '';
                  String password = prefs.getString('password') ?? '';

                  if(username != '' && password != '') {
                    LoginResponse response = await LocalDatabaseService.db.login(username, password);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthWrapper(
                          account: response.account != null &&
                              response.message == 'SUCCESS' ?
                          response.account : null)
                      ),
                    );
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthWrapper(account: null)));
                  }
                },
                child: Text('Get Started'),
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 24
                    )),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 8, horizontal: 20)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Color(0xFF459A7C)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          )
                      )
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
