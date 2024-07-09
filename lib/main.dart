import 'package:expense_tracker/database_helper.dart';
import 'package:expense_tracker/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initializeDatabaseFactory();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData.dark(),
      home: ExpenseList(),
    );
  }
}

class ExpenseList extends StatefulWidget {
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  List<Expense> expenses = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshExpenses();
  }

  void _refreshExpenses() async {
    final data = await DatabaseHelper.instance.getExpenses();
    setState(() {
      expenses = data;
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        String amount = '';
        String description = '';

        return AlertDialog(
          title: Text('Add Expense'),
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextButton(
              child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2050),
                );

                if (picked != null && picked != selectedDate)
                  selectedDate = picked;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => description = value,
            )
          ]),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () async {
                if (amount.isNotEmpty && description.isNotEmpty) {
                  final newExpense = Expense(
                      date: selectedDate,
                      amount: double.parse(amount),
                      description: description);
                  await DatabaseHelper.instance.insertExpense(newExpense);
                  _refreshExpenses();
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Tracker')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Description')),
          ],
          rows: expenses
              .map((expense) => DataRow(cells: [
                    DataCell(
                        Text(DateFormat('yyyy-MM-dd').format(expense.date))),
                    DataCell(Text(expense.amount.toString())),
                    DataCell(Text(expense.description)),
                  ]))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddExpenseDialog,
          child: Icon(Icons.account_balance_wallet)),
    );
  }
}
