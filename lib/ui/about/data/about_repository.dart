import 'package:my_wallet/ca/data/ca_repository.dart';

import 'package:my_wallet/ui/about/data/about_entity.dart';
export 'package:my_wallet/ui/about/data/about_entity.dart';

import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart' show rootBundle;

class AboutUsRepository extends CleanArchitectureRepository {

  Future<AboutEntity> loadData() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    final appName = info.appName;

    String version = "${info.version} (build ${info.buildNumber})";

    String about = await rootBundle.loadString("assets/about/About.txt");

    return AboutEntity(version, about, emphasize: appName);
  }
}