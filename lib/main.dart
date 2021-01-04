import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorting Algorithms Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sorting Algorithms Visualizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _random = Random();
  final _maxValue = 1000;
  final List<String> methods = ['Quick sort'];
  final _t = Stopwatch();
  static const _delay = Duration(microseconds: 1);

  // params
  int _size = 50;
  List<int> _values;
  String _method;

  // flags
  bool _shouldStop;
  int _ptr1;
  int _ptr2;

  void _start(Function sortFunction) {
    _shouldStop = false;
    setState(() {});

    _t
      ..reset()
      ..start();
    final refreshRate = 360;
    final refreshTimer = Timer.periodic(
        Duration(microseconds: (1000000 / refreshRate).round()),
        (_) => setState(() {}));
    sortFunction().then((_) {
      _method = null;
      _t.stop();
      refreshTimer.cancel();
      setState(() {});
    });
  }

  void _stop() => _shouldStop = true;

  void _reset() {
    _t.reset();
    _values = List.generate(_size, (_) => _random.nextInt(_size) + 1);
  }

  void _swap(int i, int j) {
    int tmp = _values[j];
    _values[j] = _values[i];
    _values[i] = tmp;
  }

  Future<void> _slowSort() async {
    for (_ptr1 = 0; _ptr1 < _size - 1; _ptr1++) {
      for (_ptr2 = _ptr1 + 1; _ptr2 < _size; _ptr2++) {
        if (_shouldStop) return;
        if (_values[_ptr2] < _values[_ptr1]) {
          _swap(_ptr1, _ptr2);
        }
        await Future.delayed(_delay);
      }
    }
  }

  Future<void> _quicksort([int start, int end]) async {
    start ??= 0;
    end ??= _values.length - 1;
    if (end <= start) return;
    _ptr1 = end;
    for (_ptr2 = start; _ptr2 < _ptr1;) {
      if (_shouldStop) return;
      if (_values[_ptr2] > _values[_ptr1]) {
        _swap(_ptr1 - 1, _ptr1);
        if (_ptr1 - 1 > _ptr2) _swap(_ptr2, _ptr1);
        _ptr1--;
      } else {
        _ptr2++;
      }
      await Future.delayed(_delay);
    }
    await _quicksort(start, _ptr1 - 1);
    await _quicksort(_ptr1 + 1, end);
  }

  Future<void> _mergeSort([int start, int end]) async {
    start ??= 0;
    end ??= _values.length - 1;
    if (end <= start) return;
    int mid = ((start + end) / 2.0).ceil();
    await _mergeSort(start, mid - 1);
    await _mergeSort(mid, end);
    List<int> tmp = [];
    _ptr1 = start;
    _ptr2 = mid;
    while (_ptr1 <= mid - 1 || _ptr2 <= end) {
      if (_ptr1 > mid - 1) {
        tmp.add(_values[_ptr2]);
        _ptr2++;
      } else if (_ptr2 > end) {
        tmp.add(_values[_ptr1]);
        _ptr1++;
      } else if (_values[_ptr1] <= _values[_ptr2]) {
        tmp.add(_values[_ptr1]);
        _ptr1++;
      } else {
        tmp.add(_values[_ptr2]);
        _ptr2++;
      }
      await Future.delayed(_delay);
    }
    for (int i = 0; i < tmp.length; i++) {
      _ptr1 = start + i;
      _values[_ptr1] = tmp[i];
      await Future.delayed(_delay);
    }
  }

  Future<void> _insertionSort() async {
    _ptr1 = 1;
    while (_ptr1 < _values.length) {
      _ptr2 = _ptr1;
      while (_ptr2 > 0 && _values[_ptr2] < _values[_ptr2 - 1]) {
        if (_shouldStop) return;
        _swap(_ptr2, _ptr2 - 1);
        _ptr2--;
        await Future.delayed(_delay);
      }
      _ptr1++;
    }
  }

  Future<void> _selectionSort() async {
    int min;
    for (_ptr1 = 0; _ptr1 < _size - 1; _ptr1++) {
      min = _ptr1;
      for (_ptr2 = _ptr1 + 1; _ptr2 < _size; _ptr2++) {
        if (_shouldStop) return;
        if (_values[_ptr2] < _values[min]) {
          min = _ptr2;
        }
        await Future.delayed(_delay);
      }
      if (_ptr1 != min) {
        _swap(min, _ptr1);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final itemWidth = media.size.width / _values.length;
    final theme = Theme.of(context);
    final methods = {
      'Slow sort': _slowSort,
      'Quicksort': _quicksort,
      'Merge sort': _mergeSort,
      'Insertion sort': _insertionSort,
      'Selection sort': _selectionSort,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Sort $_size integers',
            textAlign: TextAlign.center,
            style: theme.textTheme.headline5,
          ),
          Slider(
            min: 1.0 / _maxValue,
            max: 1.0,
            value: 1.0 * _size / _maxValue,
            onChanged: (value) =>
                setState(() => _size = (value * _maxValue / 10).ceil() * 10),
            onChangeEnd: (value) => setState(() => _reset()),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            height: theme.buttonTheme.height + 32,
            child: ListView(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              scrollDirection: Axis.horizontal,
              children: [
                for (final method in methods.keys) ...[
                  const SizedBox(width: 5),
                  _method == method
                      ? ElevatedButton(
                          onPressed: () {
                            _method = method;
                            _start(methods[method]);
                          },
                          child: Text(method),
                        )
                      : OutlinedButton(
                          onPressed: () {
                            _method = method;
                            _start(methods[method]);
                          },
                          child: Text(method),
                        ),
                ]
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _stop,
                child: Text('Stop'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() => _reset()),
                child: Text('Reset'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final heightRatio = constraints.maxHeight / _values.length;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < _values.length; i++)
                      Container(
                        color: _ptr1 == i || _ptr2 == i
                            ? Theme.of(context).accentColor
                            : Theme.of(context).primaryColor,
                        height: heightRatio * _values[i],
                        width: itemWidth,
                        alignment: Alignment.bottomCenter,
                      )
                  ],
                );
              },
            ),
          ),
          Container(
            height: 64,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              "${_t.elapsedMilliseconds}ms",
            ),
          ),
        ],
      ),
    );
  }
}
