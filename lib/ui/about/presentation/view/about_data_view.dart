import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/about/data/about_entity.dart';
export 'package:my_wallet/ui/about/data/about_entity.dart';

abstract class AboutUsDataView extends DataView {
  void updateDetail(AboutEntity entity);
}