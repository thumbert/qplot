import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:qplot/src/lib_plotly.dart';
import 'package:qplot/src/qplot_base.dart';

void main(List<String> args) {
  var parser = ArgParser()
    ..addFlag('help', abbr: 'h')
    ..addFlag('version', abbr: 'v', help: 'Current qplot version.')
    ..addOption(
      'file',
      help:
          'Html file path output.  If not specified, it will open in the current browser.',
    )
    ..addOption(
      'config',
      help:
          'Plotly config options as a JSON string.  For example: {"height": 800}.',
    )
    ..addOption(
      'mode',
      defaultsTo: 'lines',
      help:
          'Plot mode. Default is "lines". Other options are "markers", "lines+markers", "text", etc.',
    )
    ..addOption(
      'type',
      defaultsTo: 'scatter',
      help: 'Plot mode. Valid options are "bar", "pie", "box", etc.',
    )
    ..addOption(
      'input',
      allowed: ['csv', 'json'],
      help:
          """Input mode for the data.  Only CSV and JSON are supported.  If the input 
argument is not specified, QPlot looks at the first character of the input.  
If it is a "[", it is assumed to be JSON.  Otherwise, it is assumed to be CSV.

CSV input should be comma-separated rows of data with the first line as the
header.  The first column is the x-axis data, and the remaining columns are 
variables plotted on the y-axis.           

JSON input should be a JSON array of objects, where each object has the same
keys.  The first key is the x-axis data, and the remaining keys are variables.
""",
    )
    ..addOption(
      'skip',
      defaultsTo: '0',
      help:
          'Number of lines to skip at the beginning of the input.  Only applies'
          'to CSV input.',
    );

  var results = parser.parse(args);
  if (results['help']) {
    print('''
QPlot -- create a quick plot from piped input data using Plotly JS.  
See https://github.com/thumbert/qplot for more details.

Flags:
${parser.usage}

Example usage:
    echo "date,price
    2023-01-01,100
    2023-01-02,150
    2023-01-03,200
    2023-01-04,175
    2023-01-05,225
    " | qplot
  
    cat data.csv | qplot --mode=markers --type=scatter --config='{"height": 800}'  

''');
    exit(0);
  }
  if (results['version']) {
    print('0.1.2');
    exit(0);
  }
  File? file;
  if (results['file'] != null) {
    file = File(results['file'] as String);
    file.createSync(recursive: true);
  }

  final config = results['config'] != null
      ? json.decode(results['config'] as String)
      : <String, dynamic>{};
  final mode = results['mode'] as String;
  final type = results['type'] as String;

  List<String> lines = [];
  while (true) {
    String? line = stdin.readLineSync();
    if (line == null || line.isEmpty) break;
    lines.add(line);
  }
  if (lines.isEmpty) {
    print('No input data provided. Please provide data through stdin.');
    exit(1);
  }

  late String inputDataType;
  if (results['input'] == null) {
    // Determine input type based on the first character of the first line
    if (lines.first.startsWith('[')) {
      inputDataType = 'json';
    } else {
      inputDataType = 'csv';
    }
  } else {
    inputDataType = results['input'] as String;
  }

  late List<Map<String, dynamic>> traces;
  if (inputDataType == 'json') {
    traces = makeTracesJson(lines.join(), mode: mode, type: type);
  } else if (inputDataType == 'csv') {
    traces = makeTracesCsv(
      lines.skip(int.tryParse(results['skip']) ?? 0),
      mode: mode,
      type: type,
    );
  }

  Plotly.now(traces, config, file: file);
}
