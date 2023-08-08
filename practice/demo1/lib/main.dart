import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tab Example'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Input'),
                Tab(text: 'Timer'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              InputTab(onNewItemAdded: (item) {
                setState(() {
                  items.add(item);
                });
              }),
              TimerTab(items: items),
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  String name;
  Duration duration;

  Item({required this.name, required this.duration});
}

class InputTab extends StatefulWidget {
  final Function(Item) onNewItemAdded;

  InputTab({required this.onNewItemAdded});

  @override
  _InputTabState createState() => _InputTabState();
}

class _InputTabState extends State<InputTab> {
  final nameController = TextEditingController();
  int minutes = 0;
  int seconds = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Enter Item Name'),
        ),
        Row(
          children: [
            DropdownButton<int>(
              value: minutes,
              items: List.generate(
                  60,
                  (index) => DropdownMenuItem(
                      child: Text('$index minutes'), value: index)),
              onChanged: (value) {
                setState(() {
                  minutes = value!;
                });
              },
            ),
            DropdownButton<int>(
              value: seconds,
              items: List.generate(
                  60,
                  (index) => DropdownMenuItem(
                      child: Text('$index seconds'), value: index)),
              onChanged: (value) {
                setState(() {
                  seconds = value!;
                });
              },
            )
          ],
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              widget.onNewItemAdded(Item(
                  name: nameController.text,
                  duration: Duration(minutes: minutes, seconds: seconds)));
              nameController.clear();
              setState(() {
                minutes = 0;
                seconds = 0;
              });
            }
          },
        )
      ],
    );
  }
}

class TimerTab extends StatefulWidget {
  final List<Item> items;

  TimerTab({required this.items});

  @override
  _TimerTabState createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  Timer? _timer;
  int _currentIndex = 0;
  Duration _currentDuration = Duration();

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _currentDuration = widget.items[_currentIndex].duration;
      _startTimer();
    }
  }

  _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentDuration > Duration(seconds: 0)) {
          _currentDuration -= Duration(seconds: 1);
        } else {
          timer.cancel();
          _currentIndex++;
          if (_currentIndex < widget.items.length) {
            _currentDuration = widget.items[_currentIndex].duration;
            _startTimer();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: index == _currentIndex
              ? Text(
                  '${_currentDuration.inMinutes}:${_currentDuration.inSeconds % 60}')
              : Text(
                  '${item.duration.inMinutes}:${item.duration.inSeconds % 60} minutes'),
        );
      },
    );
  }
}
