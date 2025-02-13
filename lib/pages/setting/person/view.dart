import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/controller/setting/setting_controller.dart';
import 'package:orginone/dart/core/getx/base_bindings.dart';
import 'package:orginone/dart/core/getx/base_controller.dart';
import 'package:orginone/dart/core/getx/base_get_page_view.dart';
import 'package:orginone/dart/core/getx/base_get_state.dart';
import 'package:orginone/dart/core/target/person.dart';
import 'package:orginone/routers.dart';
import 'package:orginone/widget/gy_scaffold.dart';

class PersonPage extends BaseGetPageView<PersonController, PersonState> {
  var list = List.of(['carBag', 'security', 'dynamic', 'mark']);
  @override
  Widget buildView() {
    return GyScaffold(
      titleName: '个人中心',
      body: body,
    );
  }

  @override
  PersonController getController() {
    return PersonController();
  }

  Widget get body {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 170.h,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [getAvatar, getName]),
            )),
        // 卡包
        Container(
          height: 5,
        ),
        cardBag,
        Container(
          height: 5,
        ),
        //安全
        security,
        Container(
          height: 5,
        ),
        //动态
        dynamic,
        Container(
          height: 5,
        ),
        //收藏
        mark,
        Container(
          height: 5,
        ),
        //注销登录
        logout
      ]),
    );
  }

  Widget get cardBag {
    return Container(
        height: 80.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: GestureDetector(
            onTap: () {
              Get.toNamed(Routers.cardbag);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text.rich(TextSpan(text: "卡包")),
                    Icon(
                      Icons.navigate_next,
                    )
                  ]),
            )));
  }

  Widget get security {
    return Container(
        height: 80.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: GestureDetector(
            onTap: () {
              Get.toNamed(Routers.dynamic);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 5, 20, 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text.rich(TextSpan(text: "安全")),
                    Icon(
                      Icons.navigate_next,
                    )
                  ]),
            )));
  }

  Widget get dynamic {
    return Container(
        height: 80.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: GestureDetector(
            onTap: () {
              Get.toNamed(Routers.dynamic);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 5, 20, 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text.rich(TextSpan(text: "动态")),
                    Icon(
                      Icons.navigate_next,
                    )
                  ]),
            )));
  }

  Widget get mark {
    return Container(
        height: 80.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: GestureDetector(
            onTap: () {
              Get.toNamed(Routers.mark);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 5, 20, 5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text.rich(TextSpan(text: "收藏")),
                    Icon(
                      Icons.navigate_next,
                    )
                  ]),
            )));
  }

  Widget get logout {
    return Container(
        height: 80.h,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
          child: GestureDetector(
              onTap: () {
                Get.toNamed(Routers.login);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text.rich(TextSpan(text: "注 销 登 录"),
                      style: TextStyle(color: Colors.red)),
                ],
              )),
        ));
  }

  Widget get getName {
    var settingCtrl = Get.find<SettingController>();
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text.rich(TextSpan(text: settingCtrl.user!.name)),
    );
  }

  Widget get getAvatar {
    var settingCtrl = Get.find<SettingController>();
    var avatar = settingCtrl.user!.shareInfo.avatar;
    var thumbnail = avatar!.thumbnail!.split(",")[1];
    thumbnail = thumbnail.replaceAll('\r', '').replaceAll('\n', '');
    var size = 100.w;
    return AdvancedAvatar(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18.0)),
      ),
      child: Image(
        width: size,
        height: size,
        image: MemoryImage(base64Decode(thumbnail)),
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}

class PersonController extends BaseController<PersonState> {}

class PersonState extends BaseGetState {
  late final Person person;
}

class PersonBinding extends BaseBindings<PersonController> {
  @override
  PersonController getController() {
    return PersonController();
  }
}
