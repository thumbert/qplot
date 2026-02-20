import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

class Plotly {
  /// Write just the plotly js script to a file.  The div id will be the file
  /// basename.  This way, you can construct your html document the way you
  /// need.
  static void exportJs(
      List<Map<String, dynamic>> traces, Map<String, dynamic> layout,
      {required File file,
      Map<String, dynamic>? config,
      String? eventHandlers}) {
    if (extension(file.path) != '.js') {
      throw ArgumentError('Filename extension needs to be .js');
    }
    var name = basename(file.path);
    var divId = name.replaceAll(RegExp('\\.js\$'), '');
    var tracesV = '${divId}_traces';
    var layoutV = '${divId}_layout';
    config ??= {'displaylogo': false, 'responsive': true};
    var out = """
  let $divId = document.getElementById("$divId");
  let $tracesV = ${json.encode(traces)};
  let $layoutV = ${json.encode(layout)};
  Plotly.newPlot( $divId, $tracesV, $layoutV, ${json.encode(config)} );
    """;
    if (eventHandlers != null) {
      out = '$out\n'
          '$eventHandlers';
    }
    file.writeAsStringSync(out);
  }

  /// Create a plotly chart in the browser by writing your data into a
  /// temporary html file and launching chrome on it.
  static void now(
    List<Map<String, dynamic>> traces,
    Map<String, dynamic> layout, {
    Map<String, dynamic>? config,
    bool displayLogo = false,
    File? file,
  }) {
    config ??= {'displaylogo': false, 'responsive': true};
    if (!config.containsKey('displaylogo')) {
      config['displaylogo'] = false;
    }
    if (!config.containsKey('responsive')) {
      config['responsive'] = true;
    }
    bool openInBrowser = file == null;
    if (file != null && extension(file.path) != '.html') {
      throw ArgumentError('Filename extension needs to be .html');
    }
    file ??= File(
        '${Directory.systemTemp.path}/plotly_${DateTime.now().millisecondsSinceEpoch}.html');
    var divId = 'plotly-html-element';
    var out = """
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdn.plot.ly/plotly-3.3.1.min.js" charset="utf-8"></script>
</head>
<body>
  <div id="$divId"></div>
  <script type="module">
  	let graph_div = document.getElementById("$divId");
	  await Plotly.newPlot( graph_div, ${json.encode(traces)}, ${json.encode(layout)}, ${json.encode(config)} );
  </script>
</body>
</html>
""";
    file.writeAsStringSync(out);

    if (openInBrowser) {
      if (Platform.isWindows) {
        // On Windows, we can use the start command to open the file in the default browser.
        Process.runSync('start', [file.path], runInShell: true);
      } else if (Platform.isLinux || Platform.isMacOS) {
        // On Linux and macOS, we can use xdg-open or open command respectively.
        var command = Platform.isLinux ? 'xdg-open' : 'open';
        Process.runSync(command, [file.path]);
      }
    }
  }
}
