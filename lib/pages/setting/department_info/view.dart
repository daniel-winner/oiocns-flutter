import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/getx/base_get_view.dart';
import 'package:orginone/pages/setting/cofig.dart';
import 'package:orginone/util/date_utils.dart';
import 'package:orginone/util/department_management.dart';
import 'package:orginone/widget/common_widget.dart';
import 'package:orginone/widget/gy_scaffold.dart';

import 'logic.dart';
import 'state.dart';

class DepartmentInfoPage
    extends BaseGetView<DepartmentInfoController, DepartmentInfoState> {
  @override
  Widget buildView() {
    return GyScaffold(
      titleName: state.depart.value.teamName,
      body: SingleChildScrollView(
        child: Column(
          children: [
            info(),
            SizedBox(
              height: 10.h,
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: CommonWidget.commonNonIndicatorTabBar(state.tabController, tabTitle,onTap: (index){
                      controller.changeView(index);
                    }),
                  ),
                  popupMenuButton(),
                ],
              ),
            ),
            body(),
          ],
        ),
      ),
    );
  }

  Widget info(){
    return Column(
      children: [
        CommonWidget.commonHeadInfoWidget("基本信息"),
        CommonWidget.commonFormWidget(formItem: [
          CommonWidget.commonFormItem(
              title: "部门名称", content: state.depart.value.teamName),
          CommonWidget.commonFormItem(
              title: "部门代码", content: state.depart.value.target.code),
          CommonWidget.commonFormItem(
              title: "团队简称", content: state.depart.value.name),
          CommonWidget.commonFormItem(
              title: "团队标识", content: state.depart.value.target.team?.code ?? ""),
          CommonWidget.commonFormItem(
              title: "所属单位",
              content: state.settingController.company?.teamName ?? ""),
          CommonWidget.commonFormItem(
              title: "创建人",
              content: DepartmentManagement()
                  .findXTargetByIdOrName(
                  id: state.depart.value.target.team?.createUser)
                  ?.team
                  ?.name ??
                  ""),
          CommonWidget.commonFormItem(
              title: "创建时间",
              content: DateTime.tryParse(
                  state.depart.value.target.team?.createTime ?? "")!
                  .format()),
          CommonWidget.commonFormItem(
              title: "简介", content: state.depart.value.target.team?.remark ?? ""),
        ])
      ],
    );
  }

  Widget body(){
    return Obx(() {
      if (state.index.value == 1) {
        return Container();
      }
      List<XTarget> users = state.depart.value.members;
      List<List<String>> userContent = [];
      for (var user in users) {
        userContent.add([
          user.code,
          user.name,
          user.team?.name ?? "",
          user.team?.code ?? "",
          user.team?.remark ?? ""
        ]);
      }
      return CommonWidget.commonDocumentWidget(
          title: memberTitle,
          content: userContent,
          showOperation: true,
          popupMenus: [
            const PopupMenuItem(value: 'out', child: Text("踢出")),
          ],
          onOperation: (type,data) {
            controller.removeMember(data);
          });
    });
  }

  Widget popupMenuButton() {
    return Container(
      height: 50.h,
      color: Colors.white,
      child: PopupMenuButton(
        icon: Icon(
          Icons.more_vert_outlined,
          size: 32.w,
        ),
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: CompanyFunction.roleSettings,
              child: Text("角色设置"),
            ),
            const PopupMenuItem(
              value: CompanyFunction.addUser,
              child: Text("添加成员"),
            ),
          ];
        },
        onSelected: (CompanyFunction function){
          controller.companyOperation(function);
        },
        onCanceled: (){

        },
        onOpened: (){

        },
      ),
    );
  }
}
