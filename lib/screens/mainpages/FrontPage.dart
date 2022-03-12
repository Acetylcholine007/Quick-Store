import 'package:flutter/material.dart';
import 'package:quick_store/models/LoginResponse.dart';
import 'package:quick_store/services/LocalDatabaseService.dart';
import 'package:quick_store/shared/decorations.dart';
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
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: new AssetImage("assets/images/background.png"), fit: BoxFit.cover,),
        ),
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
                  Text('INVENTORY', style: theme.textTheme.bodyText1.copyWith(color: theme.primaryColorDark, fontWeight: FontWeight.w700))
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
                  style: appButtonDecoration
              ),
              SizedBox(
                height: 80,
              )
            ],
          ),
        ),
      ),
    );
  }
}
