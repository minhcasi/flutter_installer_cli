import 'dart:io';

import 'package:dio/dio.dart';

import '../../model/flutter_releases.dart';
import '../internal/config.dart';
import '../internal/tool.dart';

Future<FlutterReleases> getFlutterLatestInfo() async {
  stdout.writeln('[FLUTTER] Getting latest version info...');
  var response = await Dio().get(
    'https://storage.googleapis.com/flutter_infra/releases'
    '/releases_${Platform.operatingSystem}.json',
  );
  return FlutterReleases.fromMap(response.data);
}

Future<void> installFlutter() async {
  var flutterReleases = await getFlutterLatestInfo();
  var release = fixFlutterVersion(flutterReleases);
  var flutterZipPath = '${release.archive}'.replaceFirst(
    '${channelValues.reverse[release.channel]}/${Platform.operatingSystem}',
    '',
  );
  flutterZipPath = fixPathPlatform(downloadDir + flutterZipPath, File);
  var exists = await File(flutterZipPath).exists();
  if (!exists) {
    await downloadFile(
      title: 'FLUTTER',
      content: 'Flutter ${release.version}',
      urlPath: '${flutterReleases.baseUrl}/${release.archive}',
      savePath: flutterZipPath,
    );
  }
  await extractZip(
    title: 'FLUTTER',
    content: 'Flutter ${release.version}',
    filePath: flutterZipPath,
    savePath: installationPath,
  );
  await setPathEnvironment(
    title: 'FLUTTER',
    newPath: '${installationPath}/flutter/bin',
  );
  await setPathEnvironment(
    title: 'FLUTTER',
    newPath: '${installationPath}/flutter/bin/cache/dart-sdk/bin',
  );
}
