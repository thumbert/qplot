import 'dart:convert';

import 'package:csv/csv.dart';


List<Map<String, dynamic>> makeTracesCsv(
  Iterable<String> inputLines, {
  required String mode,
  required String type,
  required bool header,
}) {
  final content = csv.decode(inputLines.join('\n'));
  List<String> names = [];
  if (header) {
    names = content[0].map((e) => e.toString()).toList();
  } else {
    names = List.generate(content[0].length, (index) => 'col${index + 1}');
  }

  var idxOffset = header ? 1 : 0;
  var x = [];
  var series = List.generate(names.length - 1, (index) => <num?>[]);
  for (var i = idxOffset; i < content.length; i++) {
    var row = content[i];
    x.add(row[0]);
    for (var j = 1; j < row.length; j++) {
      late num? value;
      if (row[j] is String) {
        value = num.tryParse(row[j]);
      } else {
        value = row[j];
      }
      series[j - 1].add(value);
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
  var x = [];
  var series = List.generate(names.length - 1, (index) => <num?>[]);
  for (var row in content) {
    x.add(row[names[0]]);
    for (var j = 1; j < row.length; j++) {
      late num? value;
      if (row[names[j]] is String) {
        value = num.tryParse(row[names[j]]);
      } else {
        value = row[names[j]];
      }
      series[j - 1].add(value);
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
