import 'package:get/get.dart';
import 'package:infinity_wellness/app/features/partner/controller/partner_detail_controller.dart';

class PartnerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerDetailController>(() => PartnerDetailController());
  }
}
