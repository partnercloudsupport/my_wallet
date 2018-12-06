import 'package:my_wallet/ca/presentation/view/ca_dataview.dart';
import 'package:my_wallet/ui/home/chart/saving/data/chart_saving_entity.dart';

abstract class ChartSavingDataView extends DataView {
  void onDataAvailable(SavingEntity entity);
}