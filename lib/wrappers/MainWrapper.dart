import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/Account.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/screens/mainpages/DailyTallyPage.dart';
import 'package:quick_store/screens/mainpages/DataPage.dart';
import 'package:quick_store/screens/mainpages/HelpPage.dart';
import 'package:quick_store/screens/mainpages/HistoryPage.dart';
import 'package:quick_store/screens/mainpages/InventoryPage.dart';
import 'package:quick_store/screens/mainpages/ScanPage.dart';
import 'package:quick_store/services/DataService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainWrapper extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;
  final Function logoutHandler;
  final Account account;

  MainWrapper({this.bloc, this.data, this.logoutHandler, this.account});

  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool isProcessing = false;
  int _currentIndex = 0;

  void loadingHandler(bool status) {
    setState(() => isProcessing = status);
  }

  String getAccountType(bool isAnon, String type) {
    if (isAnon)
      return 'GUESS';
    if (!isAnon && type == "ADMIN")
      return 'ADMIN';
    if (!isAnon && type == "EMPLOYEE")
      return 'EMPLOYEE';
    return 'ADMIN';
  }

  void qrDownloadHandler() async {
    Navigator.of(context).pop();
    loadingHandler(true);
    String result = await DataService.ds.qrPrintHandler(context, widget.data.products);
    loadingHandler(false);
    if(result == 'SUCCESS') {
      final snackBar = SnackBar(
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        content: Text('QR images saved to your Gallery'),
        action: SnackBarAction(label: 'OK', onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Export QR Code'),
            content: Text(result),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK')
              )
            ],
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Page> pages = [
      Page(
        InventoryPage(bloc: widget.bloc, data: widget.data),
        BottomNavigationBarItem(
          label: 'Inventory',
          icon: FaIcon(FontAwesomeIcons.boxes),
        ),
      ),
      Page(
        ScanPage(bloc: widget.bloc, data: widget.data, account: widget.account),
        BottomNavigationBarItem(
          label: 'Scan',
          icon: FaIcon(FontAwesomeIcons.qrcode),
        ),
      ),
      Page(
        DailyTallyPage(bloc: widget.bloc, data: widget.data, isAll: false),
        BottomNavigationBarItem(
          label: 'Daily Tally',
          icon: FaIcon(FontAwesomeIcons.edit),
        ),
      ),
    ];
    final mainPages = pages.map((page) => page.page).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Color(0xFFF2E7E7),
        endDrawer: Drawer(
          backgroundColor: Color(0xFF423A3A).withOpacity(0.80),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF423A3A),
                ),
                margin: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(widget.account.username, style: theme.textTheme.headline6.copyWith(color: Colors.white)),
                    Text(widget.account.contact, style: theme.textTheme.headline6.copyWith(color: Colors.white))
                  ],
                ),
              ),
              ListTile(
                title: Text('History (Daily Tally)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage(bloc: widget.bloc, data: widget.data)),
                  );
                },
              ),
              ListTile(
                title: Text('Print QR Codes', style: TextStyle(color: Colors.white)),
                onTap: qrDownloadHandler,
              ),
              ListTile(
                title: Text('Manage Data', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DataPage(bloc: widget.bloc, data: widget.data)),
                  );
                }
              ),
              ListTile(
                title: Text('Help', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpPage()),
                  );
                },
              ),
              Divider(thickness: 1, height: 10, color: Colors.white, indent: 16, endIndent: 16),
              ListTile(
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('username');
                  await prefs.remove('password');
                  widget.logoutHandler();
                },
              ),
              ListTile(
                title: Text('Exit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          bottom: isProcessing ? PreferredSize(
              preferredSize: Size(double.infinity, 1.0),
              child: LinearProgressIndicator(backgroundColor: Color(0xFF459A7C))
          ) : null,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedIconTheme: IconThemeData(
            color: Colors.black
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF459A7C),
          unselectedItemColor: Colors.black.withOpacity(.50),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          currentIndex: _currentIndex,
          onTap: (value) => setState(() => _currentIndex = value),
          items: pages.map((page) => page.tab).toList(),
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
            child: mainPages[_currentIndex]
        )
      ),
    );
  }
}

class Page {
  Widget page;
  BottomNavigationBarItem tab;

  Page(this.page, this.tab);
}
