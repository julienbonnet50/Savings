// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:savings/src/saving_feature/company_referential.dart';
import 'package:savings/src/saving_feature/account_type.dart';

import '../settings/settings_view.dart';
import 'saving.dart';
import 'saving_details_view.dart';
import 'package:csv/csv.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show rootBundle;

final logger = Logger();

/// Displays a list of Savings.
class SavingListView extends StatefulWidget {
  const SavingListView({
    super.key,
    this.items = const [
      Saving(
        id: 1,
        name: "Compte courrant Julien SG",
        companyId: 0,
        accountTypeId: 0,
        growthRatio: 7,
        currency: 45000.0,
        startDate: "2015-05-16"
      ), 
      Saving(
        id: 2,
        name: "PEA Julien BNP",
        companyId: 1,
        accountTypeId: 1,
        growthRatio: 1.7,
        currency: 17825.0,
        startDate: "2015-05-16"
      ), 
      Saving(
        id: 1,
        name: "PEE Julien Credit agricole",
        companyId: 2,
        accountTypeId: 3,
        growthRatio: 1.7,
        currency: 17825.0,
        startDate: "2015-05-16"
      )],
  });

  static const routeName = '/';

  final List<Saving> items;

  @override
  _SavingListViewState createState() => _SavingListViewState();
  }

class _SavingListViewState extends State<SavingListView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _growthRatioController = TextEditingController();
  final _currencyController = TextEditingController();
  final _dateController = TextEditingController();


  late List<Saving> _items;
  List<CompanyReferential> _companyReferential = [];
  List<AccountType> _accountTypes = [];

  AccountType? _selectedAccountType;
  CompanyReferential? _selectedCompany;
  late Future<void> _dataLoaded;

  Future<void> _loadAccountTypeFromCsv() async {
  final csvData = await rootBundle.loadString("./assets/data/accountTypeReferential.csv");
  final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

  setState(() {
    _accountTypes = rows.skip(1).map((row) {
      logger.i(row[0], row[1]);
      return AccountType(
        row[0],
        row[1]
      );
    }).toList();
  });
}

  Future<void> _loadCompanyReferentialFromCsv() async {
  final csvData = await rootBundle.loadString("./assets/data/companyReferential.csv");
  final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

  setState(() {
    _companyReferential = rows.skip(1).map((row) {
      return CompanyReferential(
        row[0],
        row[1],
        row[2]
      );
    }).toList();
  });
}

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataLoaded = Future.wait([
      _loadAccountTypeFromCsv(),
      _loadCompanyReferentialFromCsv(),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataLoaded,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Current savings'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to the settings page. If the user leaves and returns
                  // to the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.restorablePushNamed(context, SettingsView.routeName);
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Navigation Menu'),
                ),
                ListTile(
                  title: const Text('Home'),
                  onTap: () {
                    // Handle navigation to home page
                  },
                ),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () {
                    // Handle navigation to settings page
                  },
                ),
              ],
            ),
          ),
          // To work with lists that may contain a large number of items, it’s best
          // to use the ListView.builder constructor.
          //
          // In contrast to the default ListView constructor, which requires
          // building all Widgets up front, the ListView.builder constructor lazily
          // builds Widgets as they’re scrolled into view.
          body: ListView.builder(
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
            restorationId: 'SavingListView',
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _items[index];
              return ListTile(
                title: Text(item.name),
                leading: CircleAvatar(
                  // Display the Flutter Logo image asset.
                  foregroundImage: AssetImage(_companyReferential[item.companyId].iconPath),
                ),
                onTap: () {
                  // Navigate to the details page. If the user leaves and returns to
                  // the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavingDetailsView(saving: item),
                    ),
                  );
                }
              );
            },
          ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add New Item'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          DropdownButtonFormField<AccountType>(
                            value: _selectedAccountType,
                            decoration: const InputDecoration(labelText: 'Account Type'),
                            items: _accountTypes.map((AccountType accountType) {
                              return DropdownMenuItem<AccountType>(
                                value: accountType,
                                child: Text(accountType.name),
                              );
                            }).toList(),
                            onChanged: (AccountType? newValue) {
                              setState(() {
                                _selectedAccountType = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an account type';
                              }
                              return null;
                            },
                          ),
                          DropdownButtonFormField<CompanyReferential>(
                            value: _selectedCompany,
                            decoration: const InputDecoration(labelText: 'Company Type'),
                            items: _companyReferential.map((CompanyReferential companyReferential) {
                              return DropdownMenuItem<CompanyReferential>(
                                value: companyReferential,
                                child: Text(companyReferential.name),
                              );
                            }).toList(),
                            onChanged: (CompanyReferential? newValue) {
                              setState(() {
                                _selectedCompany = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an company type';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _growthRatioController,
                            decoration: const InputDecoration(labelText: 'Growth Ratio'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a growth ratio';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _currencyController,
                            decoration: const InputDecoration(labelText: 'Currency'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a currency';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(labelText: 'Date'),
                            readOnly: true,
                            onTap: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                _dateController.text = selectedDate.toString();
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a date';
                              }
                              return null;
                            },
                          ),

                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newItem = Saving(
                              id: _items.length + 1,
                              name: _nameController.text,
                              companyId: _selectedCompany!.id,
                              accountTypeId: _selectedAccountType!.id,
                              growthRatio: double.parse(_growthRatioController.text),
                              currency: double.parse(_currencyController.text),
                              startDate: _dateController.text
                            );
                            setState(() {
                              _items.add(newItem);
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Add New Item',
            child: const Icon(Icons.add),
          ),
        );
      } 
    });
  }
}
