import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/screens/mainpages/DailyTallyPage.dart';
import 'package:quick_store/screens/mainpages/HelpPage.dart';
import 'package:quick_store/screens/mainpages/HistoryPage.dart';
import 'package:quick_store/screens/mainpages/InventoryPage.dart';
import 'package:quick_store/screens/mainpages/ScanPage.dart';
import 'package:quick_store/screens/mainpages/SettingsPage.dart';
import 'package:quick_store/services/DataService.dart';

class MainWrapper extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  MainWrapper({this.bloc, this.data});

  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool isProcessing = false;
  int _currentIndex = 0;
  List<Page> pages;

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
  void initState() {
    pages = [
      Page(
          InventoryPage(bloc: widget.bloc, data: widget.data),
          BottomNavigationBarItem(
            label: 'Inventory',
            icon: Icon(Icons.archive_rounded),
          ),
      ),
      Page(
          ScanPage(),
          BottomNavigationBarItem(
            label: 'Scan',
            icon: Icon(Icons.qr_code_scanner_rounded),
          ),
      ),
      Page(
          DailyTallyPage(bloc: widget.bloc, data: widget.data),
          BottomNavigationBarItem(
            label: 'Daily Tally',
            icon: Icon(Icons.receipt_long_rounded),
          ),
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainPages = pages.map((page) => page.page).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Color(0xFFE1DBDB),
        endDrawer: Drawer(
          backgroundColor: Color(0xFF423A3A).withOpacity(0.80),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF423A3A),
                ),
                margin: EdgeInsets.all(0),
                child: Text(
                  'Quick Shop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('History (Daily Tally)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                },
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
              ListTile(
                title: Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Print QR Codes', style: TextStyle(color: Colors.white)),
                onTap: qrDownloadHandler,
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
              child: LinearProgressIndicator(backgroundColor: Colors.white)
          ) : null,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.primaryColor,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withOpacity(.60),
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
