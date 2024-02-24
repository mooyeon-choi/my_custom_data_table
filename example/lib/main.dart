import 'package:flutter/material.dart';
import 'package:my_custom_data_table/my_custom_data_table.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Custom Data Table Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: MyHomePage()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage();

  @override
  Widget build(BuildContext context) {
    return const MyCustomDataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: [
          MyCustomDataColumn(
            label: Text('Column A'),
            value: 'Column A',
            size: ColumnSize.L,
          ),
          MyCustomDataColumn(
            label: Text('Column B'),
            value: 'Column B',
          ),
          MyCustomDataColumn(
            label: Text('Column C'),
            value: 'Column C',
          ),
          MyCustomDataColumn(
            label: Text('Column D'),
            value: 'Column D',
          ),
          MyCustomDataColumn(
            label: Text('Column NUMBERS'),
            value: 'Column NUMBERS',
            numeric: true,
          ),
        ],
        data: [
          {
            'Column A': 'A1',
            'Column B': 'B1',
            'Column C': 'C1',
            'Column D': 'D1',
            'Column NUMBERS': 1,
          },
          {
            'Column A': 'A2',
            'Column B': 'B2',
            'Column C': 'C2',
            'Column D': 'D2',
            'Column NUMBERS': 2,
          },
          {
            'Column A': 'A3',
            'Column B': 'B3',
            'Column C': 'C3',
            'Column D': 'D3',
            'Column NUMBERS': 3,
          }
        ]);
  }
}
