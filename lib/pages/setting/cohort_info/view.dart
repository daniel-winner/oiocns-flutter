import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/core/getx/base_get_view.dart';
import 'package:orginone/dart/core/target/targetMap.dart';
import 'package:orginone/pages/setting/config.dart';
import 'package:orginone/util/date_utils.dart';
import 'package:orginone/util/department_management.dart';
import 'package:orginone/widget/common_widget.dart';
import 'package:orginone/widget/gy_scaffold.dart';

import '../widget.dart';
import 'logic.dart';
import 'state.dart';

class CohortInfoPage extends BaseGetView<CohortInfoController,CohortInfoState>{
  @override
  Widget buildView() {
    return GyScaffold(
      titleName: state.cohort.teamName,
      body: SingleChildScrollView(
        child: Column(
          children: [
            cohortInfo(),
            Column(
              children: [
                CommonWidget.commonHeadInfoWidget("群组人员",action: CommonWidget.commonPopupMenuButton(
                  items: const [
                    PopupMenuItem(
                      value: CompanyFunction.roleSettings,
                      child: Text("角色设置"),
                    ),
                    PopupMenuItem(
                      value: CompanyFunction.addUser,
                      child: Text("邀请成员"),
                    ),
                  ],
                  onSelected: (CompanyFunction function) {
                    controller.companyOperation(function);
                  },color: Colors.transparent
                ),),
                Obx((){
                  List<List<String>> memberContent = [];
                  for (var user in state.unitMember) {
                    memberContent.add([
                      user.code,
                      user.name,
                      user.team?.name ?? "",
                      user.team?.code ?? "",
                      user.team?.remark ?? ""
                    ]);
                  }
                  return CommonWidget.commonDocumentWidget(
                      title: memberTitle,
                      content: memberContent,
                      showOperation: true,
                      popupMenus: [
                        const PopupMenuItem(value: 'out', child: Text("移除")),
                      ],
                      onOperation: (type,data) {
                        controller.removeMember(data);
                      });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget cohortInfo() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "群组信息",
            style: TextStyle(fontSize: 21.sp),
          ),
          CommonWidget.commonTextContentWidget(
              "群组名称", state.cohort.target.team?.name ?? ""),
          CommonWidget.commonTextContentWidget(
              "群组代码", state.cohort.target.code),
          CommonWidget.commonTextContentWidget(
              "团队简称", state.cohort.name),
          CommonWidget.commonTextContentWidget(
              "团队标识", state.cohort.target.team?.code??""),
          CommonWidget.commonTextContentWidget(
              "创建人", findTargetShare(state.cohort.target.createUser).name),
          CommonWidget.commonTextContentWidget(
              "创建时间", DateTime.tryParse(
              state.cohort.target.team?.createTime ?? "")!
              .format()),
          CommonWidget.commonTextContentWidget(
              "简介", state.cohort.target.team?.remark ?? ""),
        ],
      ),
    );
  }
}
