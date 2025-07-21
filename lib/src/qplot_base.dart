import 'dart:convert';

import 'package:csv/csv.dart';

/// First input line is the column names
List<Map<String, dynamic>> makeTracesCsv(
  List<String> inputLines, {
  required String mode,
  required String type,
}) {
  final converter = CsvToListConverter(
    eol: '\n',
    fieldDelimiter: ',',
    shouldParseNumbers: true,
  );
  var content = inputLines.map((e) => converter.convert(e).first).toList();
  var names = content[0].map((e) => e.toString()).toList();
  var x = <String>[];
  var series = List.generate(names.length - 1, (index) => <num>[]);
  for (var i = 1; i < content.length; i++) {
    var row = content[i];
    x.add(row[0]);
    for (var j = 1; j < row.length; j++) {
      series[j - 1].add(row[j]);
    }
  }

  var traces = <Map<String, dynamic>>[];
  for (var i = 0; i < series.length; i++) {
    traces.add({
      'x': [...x],
      'y': series[i],
      'name': names[i + 1],
      'mode': mode,
      'type': type,
    });
  }
  return traces;
}

/// Column names are taken from the first entry in the JSON array.
List<Map<String, dynamic>> makeTracesJson(
  String input, {
  required String mode,
  required String type,
}) {
  if (!input.startsWith('[')) {
    throw ArgumentError('Input must be a JSON array string.');
  }
  var content = (json.decode(input) as List).cast<Map<String, dynamic>>();
  var names = content[0].keys.toList();
  var x = <String>[];
  var series = List.generate(names.length - 1, (index) => <num>[]);
  for (var row in content) {
    x.add(row[names[0]]);
    for (var j = 1; j < row.length; j++) {
      series[j - 1].add(row[names[j]]);
    }
  }

  var traces = <Map<String, dynamic>>[];
  for (var i = 0; i < series.length; i++) {
    traces.add({
      'x': [...x],
      'y': series[i],
      'name': names[i + 1],
      'mode': mode,
      'type': type,
    });
  }
  return traces;
}
