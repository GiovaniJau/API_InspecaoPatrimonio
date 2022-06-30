import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'endPoints.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
var portEnv = Platform.environment['PORT'];
var _hostname = portEnv == null ? 'localhost' : '0.0.0.0';
//const _hostname = '0.0.0.0';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var server = await shelf_io.serve(EndPoints().handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');

  // Enable content compression
  server.autoCompress = true;
}
