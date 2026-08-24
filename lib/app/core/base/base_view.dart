import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinity_wellness/app/constant/resources/app_colors.dart';
import 'package:infinity_wellness/app/core/base/base_controller.dart';

abstract class BaseView<T extends BaseController> extends GetView<T> {
  const BaseView({super.key});

  Widget buildView(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          buildView(context),
          if (controller.isLoading.value)
            const ColoredBox(
              color: AppColors.barrier,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
