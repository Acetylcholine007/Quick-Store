import 'package:flutter/material.dart';
import 'package:quick_store/screens/mainpages/DailyTallyPage.dart';
import 'package:quick_store/screens/mainpages/InventoryPage.dart';
import 'package:quick_store/screens/mainpages/ScanPage.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
// import 'package:quick_store/components/AccountSuspended.dart';
// import 'package:quick_store/components/Loading.dart';
// import 'package:quick_store/models/Account.dart';
// import 'package:quick_store/models/AccountData.dart';
// import 'package:quick_store/models/AppTask.dart';
//
// import 'package:quick_store/screens/mainpages/AccountPage.dart';
// import 'package:quick_store/screens/mainpages/DataPage.dart';
// import 'package:quick_store/screens/mainpages/GuessHelpPage.dart';
// import 'package:quick_store/screens/mainpages/GuessProfilePage.dart';
// import 'package:quick_store/screens/mainpages/HelpPage.dart';
// import 'package:quick_store/screens/mainpages/InventoryGlobalPage.dart';
// import 'package:quick_store/screens/mainpages/InventoryLocalPage.dart';
// import 'package:quick_store/screens/mainpages/ProfilePage.dart';
// import 'package:provider/provider.dart';
//
class MainWrapper extends StatefulWidget {
  // final Account account;
  //
  // MainWrapper({this.account});

  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  List<Page> pages;

  String getAccountType(bool isAnon, String type) {
    if (isAnon)
      return 'GUESS';
    if (!isAnon && type == "ADMIN")
      return 'ADMIN';
    if (!isAnon && type == "EMPLOYEE")
      return 'EMPLOYEE';
    return 'ADMIN';
  }

  @override
  void initState() {
    pages = [
      Page(
          InventoryPage(),
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
          DailyTallyPage(),
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
    // final account = widget.account.isAnon ? null : Provider.of<AccountData>(context);

    // return Container(
    //   child: Text('Quick App'),
    // );
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        backgroundColor: Color(0xFFE1DBDB),
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(icon: Icon(Icons.menu_rounded), onPressed: () {})
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.60),
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
