import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/config/color.dart';
import 'package:orginone/dart/core/getx/base_get_list_page_view.dart';
import 'package:orginone/pages/other/ware_house/ware_house_management/state.dart';
import 'package:orginone/routers.dart';
import 'package:orginone/util/common_tree_management.dart';
import 'package:orginone/widget/common_widget.dart';
import 'item.dart';
import 'logic.dart';

class WareHouseManagementPage extends BaseGetListPageView<
    WareHouseManagementController, WareHouseManagementState> {
  @override
  Widget buildView() {
    return Container(
      color: GYColors.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            RecentlyOpened(),
            entity(),
          ],
        ),
      ),
    );
  }

  @override
  Widget headWidget() {
    // TODO: implement headWidget
    return Column(
      children: [
        CommonWidget.commonNonIndicatorTabBar(state.tabController, tabTitle,
            onTap: (int index) {
          controller.changeIndex(index);
        }),
      ],
    );
  }

  Widget RecentlyOpened() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, top: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "最近打开",
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 51, 52, 54)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.recentlyList.map((value) {
                Widget child = button(value);
                if (state.recentlyList.indexOf(value) !=
                    (state.recentlyList.length - 1)) {
                  child = Container(
                    margin: EdgeInsets.only(right: 15.w),
                    child: child,
                  );
                }
                return child;
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget button(Recent recent) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.file);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(27.w)),
              color: Colors.black,
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(recent.url)),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            recent.name,
            maxLines: 1,
            style: TextStyle(
                fontSize: 14.sp,
                color: const Color.fromARGB(255, 52, 52, 54),
                overflow: TextOverflow.ellipsis
                // color: Colors.black
                ),
          )
        ],
      ),
    );
  }

  Widget entity() {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidget.commonBreadcrumbNavWidget(
            firstTitle: "仓库",
            allTitle: [],
          ),
          Obx(() {
            var list = [];
            CommonTreeManagement().species?.children.forEach((element) {
              if(element.name == "财物"){
                list.addAll(element.children);
              }
            });
            return Column(
              children: list.map(
                (e) {
                  return GbItem(
                    item: e,
                    next: () {
                      controller.selectSpecies(e);
                    },
                  );
                },
              ).toList(),
            );
          })
        ],
      ),
    );
  }

  @override
  WareHouseManagementController getController() {
    return WareHouseManagementController();
  }

  @override
  String tag() {
    // TODO: implement tag
    return 'WareHouseManagement';
  }

  @override
  bool displayNoDataWidget() {
    // TODO: implement displayNoDataWidget
    return false;
  }
}
