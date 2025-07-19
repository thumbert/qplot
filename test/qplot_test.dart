import 'dart:io';

import 'package:qplot/qplot.dart';
import 'package:test/test.dart';

void main() {
  group('qplot tests', () {
    test('qplot make traces csv', () {
      final file = File('test/assets/data1.csv');
      final input = file.readAsLinesSync();
      final traces = makeTracesCsv(input, mode: 'lines', type: 'scatter');
      expect(traces.length, 1);
      expect(traces.first, {
        'x': [
          '2023-01-01',
          '2023-01-02',
          '2023-01-03',
          '2023-01-04',
          '2023-01-05',
        ],
        'y': [100, 150, 200, 175, 225],
        'name': 'price',
        'mode': 'lines',
        'type': 'scatter',
      });
    });
    test('qplot make traces json', () {
      final file = File('test/assets/data1.json');
      final input = file.readAsStringSync();
      final traces = makeTracesJson(input, mode: 'lines', type: 'scatter');
      expect(traces.length, 2);
      expect(traces.first, {
        'x': ['LGA', 'BOS', 'BWI'],
        'y': [85.2, 82.2, 87.1],
        'name': 'tMin',
        'mode': 'lines',
        'type': 'scatter',
      });
    });
    test('run command line', () {
      var res = Process.runSync('bash', [
        '-c',
        'cat test/assets/data1.csv | qplot',
      ]);
      expect(res.exitCode, 0);
    }, skip: true);
  });
}
