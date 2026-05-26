import 'dart:io';

import 'package:qplot/qplot.dart';
import 'package:test/test.dart';

void main() {
  group('qplot tests', () {
    test('qplot make traces csv', () {
      final file = File('test/assets/data1.csv');
      final input = file.readAsLinesSync();
      final traces = makeTracesCsv(
        input,
        mode: 'lines',
        type: 'scatter',
        header: true,
      );
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
    test('qplot make traces csv with group', () {
      final file = File('test/assets/data2.csv');
      final input = file.readAsLinesSync();
      final traces = makeTracesCsvGrouped(
        input,
        mode: 'lines',
        type: 'scatter',
        header: true,
      );
      expect(traces.length, 2);
      expect(traces.first, {
        'x': [
          '2023-01-01',
          '2023-01-02',
          '2023-01-03',
          '2023-01-04',
          '2023-01-05',
        ],
        'y': [100, 150, 200, 175, 225],
        'name': '4000',
        'mode': 'lines',
        'type': 'scatter',
      });
      expect(traces.last, {
        'x': [
          '2023-01-01',
          '2023-01-02',
          '2023-01-03',
          '2023-01-04',
          '2023-01-05',
        ],
        'y': [200, 250, 300, 275, 325],
        'name': '4008',
        'mode': 'lines',
        'type': 'scatter',
      });
    });
    test('qplot make traces with nulls csv', () {
      final file = File('test/assets/data_with_nulls.csv');
      final input = file.readAsLinesSync();
      final traces = makeTracesCsv(
        input,
        mode: 'lines',
        type: 'scatter',
        header: true,
      );
      expect(traces.length, 7);
      expect(traces.first, {
        'x': ['2015-01', '2015-02', '2015-03', '2015-04', '2015-05'],
        'y': [35.8, 35.8, 49.3, 37.3, 42.9],
        'name': 'BIOFUEL',
        'mode': 'lines',
        'type': 'scatter',
      });
      expect(traces[4], {
        'x': ['2015-01', '2015-02', '2015-03', '2015-04', '2015-05'],
        'y': [null, 42.1, null, null, null],
        'name': 'OTHER',
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
    test('qplot make traces json with group', () {
      final file = File('test/assets/data2.json');
      final input = file.readAsStringSync();
      final traces = makeTracesJsonGrouped(
        input,
        mode: 'lines',
        type: 'scatter',
      );
      expect(traces.length, 2);
      expect(
        traces.map((trace) => trace['name']),
        containsAll(['4000', '4008']),
      );
      expect((traces.first['x'] as List).length, 72);
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
