import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/core/getx/base_get_page_view.dart';
import 'package:orginone/dart/core/target/authority/iidentity.dart';
import 'package:orginone/util/date_utils.dart';
import 'package:orginone/widget/common_widget.dart';

import 'logic.dart';
import 'state.dart';

class IdentityInfoPage
    extends BaseGetPageView<IdentityInfoController, IdentityInfoState> {
  late Rx<IIdentity> identity;

  IdentityInfoPage(IIdentity identity) {
    this.identity = Rx(identity);
  }

  @override
  Widget buildView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          identityInfo(),
          body(),
        ],
      ),
    );
  }

  Widget identityInfo() {
    return Column(
      children: [
        CommonWidget.commonHeadInfoWidget(
            "角色信息", action: identityPopupMenuButton()),
        Obx(() {
          return CommonWidget.commonFormWidget(formItem: [
            CommonWidget.commonFormItem(
                title: "名称", content: identity.value.target.name ?? ""),
            CommonWidget.commonFormItem(
                title: "编码", content: identity.value.target.code ?? ""),
            CommonWidget.commonFormItem(
                title: "创建人", content: identity.value.target.createUser ?? ""),
            CommonWidget.commonFormItem(
                title: "创建时间",
                content: DateTime.tryParse(
                    identity.value.target.createTime ?? "")!
                    .format()),
            CommonWidget.commonFormItem(
                title: "描述", content: identity.value.target.remark ?? ""),
          ]);
        })
      ],
    );
  }

  Widget body() {
    return Column(
      children: [
        Obx(() {
          return CommonWidget.commonHeadInfoWidget(
              identity.value.name, action: memberPopupMenuButton());
        }),
        Obx(() {
          List<List<String>> docContent = [];
          for (var user in state.unitMember) {
            docContent.add([
              user.code,
              user.name,
              user.team?.name ?? "",
              user.team?.remark ?? "",
              user.team?.code ?? "",
            ]);
          }
          return CommonWidget.commonDocumentWidget(
              title: docTitle,
              content: docContent,
              showOperation: true,
              popupMenus: [
                const PopupMenuItem(value: 'out', child: Text("移除")),
              ],
              onOperation: (type, data) {
                controller.removeRole(data);
              });
        }),
      ],
    );
  }

  Widget identityPopupMenuButton() {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_outlined,
        size: 32.w,
      ),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: IdentityFunction.edit,
            child: Text("编辑"),
          ),
          const PopupMenuItem(
            value: IdentityFunction.delete,
            child: Text("删除"),
          ),
        ];
      },
      onSelected: (IdentityFunction function) {
        controller.identityOperation(function);
      },
      onCanceled: () {},
      onOpened: () {},
    );
  }

  Widget memberPopupMenuButton() {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_outlined,
        size: 32.w,
      ),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(
            value: IdentityFunction.addMember,
            child: Text("指派角色"),
          ),
        ];
      },
      onSelected: (IdentityFunction function) {
        controller.identityOperation(function);
      },
      onCanceled: () {},
      onOpened: () {},
    );
  }


  @override
  IdentityInfoController getController() {
    // TODO: implement getController
    return IdentityInfoController(identity);
  }

  @override
  String tag() {
    // TODO: implement tag
    return "IdentityInfo_${identity.value.name}";
  }
}
