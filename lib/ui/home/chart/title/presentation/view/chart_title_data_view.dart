import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/chart/title/data/chart_title_entity.dart';

abstract class ChartTitleDataView extends DataView {
  void onDetailLoaded(ChartTitleEntity value);
}