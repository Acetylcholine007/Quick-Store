import 'package:flutter/material.dart';
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
  bool isGlobalImporting = false;
  int taskLength = 0;
  int taskIndex = 0;
  // List<AppTask> tasks = [AppTask(heading: 'Initializing', content: '')];

  // void globalImportLoadingHandler(bool status) {
  //   setState(() {
  //     if(!status) {
  //       taskIndex = 0;
  //       tasks = [AppTask(heading: 'Initializing', content: '')];
  //     }
  //     isGlobalImporting = status;
  //
  //     pages[0] = Page(
  //         DataPage(
  //           globalImportLoadingHandler: globalImportLoadingHandler,
  //           initializeTaskList: initializeTaskList,
  //           incrementLoading: incrementLoading,
  //           isGlobalImporting: isGlobalImporting,
  //           taskLength: taskLength,
  //           taskIndex: taskIndex,
  //           tasks: tasks,
  //         ),
  //         BottomNavigationBarItem(
  //           label: 'Data',
  //           icon: Icon(Icons.archive_rounded),
  //         ),
  //         1
  //     );
  //   });
  // }
  //
  // void initializeTaskList(List<AppTask> tasks) {
  //   setState(() {
  //     this.tasks = tasks;
  //   });
  // }
  //
  // void incrementLoading() {
  //   setState(() {
  //     taskIndex++;
  //     pages[0] = Page(
  //         DataPage(
  //           globalImportLoadingHandler: globalImportLoadingHandler,
  //           initializeTaskList: initializeTaskList,
  //           incrementLoading: incrementLoading,
  //           isGlobalImporting: isGlobalImporting,
  //           taskLength: taskLength,
  //           taskIndex: taskIndex,
  //           tasks: tasks,
  //         ),
  //         BottomNavigationBarItem(
  //           label: 'Data',
  //           icon: Icon(Icons.archive_rounded),
  //         ),
  //         1
  //     );
  //   });
  // }
  //
  // Future<String> scanCode() async {
  //   var result = await BarcodeScanner.scan();
  //   return result.rawContent;
  // }

  String getAccountType(bool isAnon, String type) {
    if (isAnon)
      return 'GUESS';
    if (!isAnon && type == "ADMIN")
      return 'ADMIN';
    if (!isAnon && type == "EMPLOYEE")
      return 'EMPLOYEE';
    return 'ADMIN';
  }

  List<Widget> getPages(String accountType) {
    if(accountType == 'GUESS')
      return pages
          .where((page) => page.accessLevel <= 1)
          .map((page) => page.page)
          .toList();
    if(accountType == 'EMPLOYEE')
      return pages
          .where((page) => page.accessLevel <= 2)
          .map((page) => page.page)
          .toList();
    if(accountType == 'ADMIN')
      return pages
          .where((page) => page.accessLevel <= 3)
          .map((page) => page.page)
          .toList();
    return [];
  }

  List<BottomNavigationBarItem> getTabs(String accountType) {
    if(accountType == 'GUESS')
      return pages
          .where((page) => page.accessLevel <= 1)
          .map((page) => page.tab)
          .toList();
    if(accountType == 'EMPLOYEE')
      return pages
          .where((page) => page.accessLevel <= 2)
          .map((page) => page.tab)
          .toList();
    if(accountType == 'ADMIN')
      return pages
          .where((page) => page.accessLevel <= 3)
          .map((page) => page.tab)
          .toList();
    return [];
  }

  @override
  void initState() {
    pages = [
      // Page(
      //     DataPage(
      //       globalImportLoadingHandler: globalImportLoadingHandler,
      //       initializeTaskList: initializeTaskList,
      //       incrementLoading: incrementLoading,
      //       isGlobalImporting: isGlobalImporting,
      //       taskLength: taskLength,
      //       taskIndex: taskIndex,
      //       tasks: tasks,
      //     ),
      //     BottomNavigationBarItem(
      //       label: 'Data',
      //       icon: Icon(Icons.archive_rounded),
      //     ),
      //     1
      // ),
      // Page(
      //     InventoryLocalPage(),
      //     BottomNavigationBarItem(
      //       label: 'Local',
      //       icon: Icon(Icons.sd_card_rounded),
      //     ),
      //     1
      // ),
      // Page(
      //     InventoryGlobalPage(),
      //     BottomNavigationBarItem(
      //       label: 'Global',
      //       icon: Icon(Icons.storage_rounded),
      //     ),
      //     2
      // ),
      // Page(
      //     AccountPage(),
      //     BottomNavigationBarItem(
      //       label: 'Accounts',
      //       icon: Icon(Icons.group_rounded),
      //     ),
      //     3
      // ),
      // Page(
      //     widget.account.isAnon ? GuessProfilePage() : ProfilePage(),
      //     BottomNavigationBarItem(
      //       label: 'Profile',
      //       icon: Icon(Icons.account_circle_rounded),
      //     ),
      //     1
      // ),
      // Page(
      //     widget.account.isAnon ? GuessHelpPage() : HelpPage(),
      //     BottomNavigationBarItem(
      //       label: 'Help',
      //       icon: Icon(Icons.help_rounded),
      //     ),
      //     1
      // ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final account = widget.account.isAnon ? null : Provider.of<AccountData>(context);

    return Container(
      child: Text('Quick App'),
    );
    // return !widget.account.isAnon && account == null ? Loading('Loading Account Data') : Builder(
    //   builder: (context) {
    //     final pages = getPages(widget.account.isAnon ? 'GUESS' : account.accountType);
    //     final tabs = getTabs(widget.account.isAnon ? 'GUESS' : account.accountType);
    //
    //     if(!widget.account.isAnon && !account.isVerified)
    //       return AccountSuspended();
    //
    //     return GestureDetector(
    //       onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
    //       child: Scaffold(
    //           bottomNavigationBar: BottomNavigationBar(
    //             type: BottomNavigationBarType.fixed,
    //             backgroundColor: theme.primaryColor,
    //             selectedItemColor: Colors.white,
    //             unselectedItemColor: Colors.white.withOpacity(.60),
    //             selectedFontSize: 14,
    //             unselectedFontSize: 14,
    //             currentIndex: _currentIndex,
    //             onTap: (value) => setState(() => _currentIndex = value),
    //             items: tabs,
    //           ),
    //           body: Container(
    //               child: pages[_currentIndex]
    //           )
    //       ),
    //     );
    //   },
    // );
  }
}

class Page {
  Widget page;
  BottomNavigationBarItem tab;
  int accessLevel;

  Page(this.page, this.tab, this.accessLevel);
}
