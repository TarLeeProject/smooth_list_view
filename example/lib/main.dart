import 'package:fluid_list_view/fluid_list_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smooth List View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Smooth List View - Horizontal')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 32,
              children: [
                SizedBox(
                  height: 200,
                  child: SmoothListView(
                    itemCount: _demo.length,
                    itemSize: 64,
                    spacing: 16,
                    delayFactor: 2,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: _demo[index].color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _demo[index].text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onEndReached: () => debugPrint('End reached'),
                    onTopReached: () => debugPrint('Top reached'),
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  child: Center(child: Text('Action')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final _demo = [
    (text: 'Item 1', color: Colors.blueAccent),
    (text: 'Item 2', color: Colors.red),
    (text: 'Item 3', color: Colors.green),
    (text: 'Item 4', color: Colors.yellow),
    (text: 'Item 5', color: Colors.purple),
    (text: 'Item 6', color: Colors.orange),
    (text: 'Item 7', color: Colors.pink),
    (text: 'Item 8', color: Colors.cyan),
    (text: 'Item 9', color: Colors.brown),
    (text: 'Item 10', color: Colors.teal),
    (text: 'Item 11', color: Colors.blueAccent),
    (text: 'Item 12', color: Colors.red),
    (text: 'Item 13', color: Colors.green),
    (text: 'Item 14', color: Colors.yellow),
    (text: 'Item 15', color: Colors.purple),
    (text: 'Item 16', color: Colors.orange),
    (text: 'Item 17', color: Colors.pink),
    (text: 'Item 18', color: Colors.cyan),
    (text: 'Item 19', color: Colors.brown),
    (text: 'Item 20', color: Colors.teal),
    (text: 'Item 21', color: Colors.blueAccent),
    (text: 'Item 22', color: Colors.red),
    (text: 'Item 23', color: Colors.green),
    (text: 'Item 24', color: Colors.yellow),
    (text: 'Item 25', color: Colors.purple),
    (text: 'Item 26', color: Colors.orange),
    (text: 'Item 27', color: Colors.pink),
    (text: 'Item 28', color: Colors.cyan),
    (text: 'Item 29', color: Colors.brown),
    (text: 'Item 30', color: Colors.teal),
  ];
}
