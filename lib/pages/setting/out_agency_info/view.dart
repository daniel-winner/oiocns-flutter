import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/core/getx/base_get_view.dart';
import 'package:orginone/dart/core/target/targetMap.dart';
import 'package:orginone/pages/setting/config.dart';
import 'package:orginone/pages/setting/widget.dart';
import 'package:orginone/util/date_utils.dart';
import 'package:orginone/widget/common_widget.dart';
import 'package:orginone/widget/gy_scaffold.dart';

import 'logic.dart';
import 'state.dart';

class OutAgencyInfoPage
    extends BaseGetView<OutAgencyInfoController, OutAgencyInfoState> {
  @override
  Widget buildView() {
    return GyScaffold(
      titleName: state.group.teamName,
      body: SingleChildScrollView(
        child: Column(
          children: [
            info(),
            SizedBox(height: 10.h,),
            Row(
              children: [
                Expanded(
                  child: CommonWidget.commonNonIndicatorTabBar(state.tabController, tabTitle,
                      onTap: (index) {
                        controller.changeView(index);
                      }),
                ),
                CommonWidget.commonPopupMenuButton(
                    items: const [
                      PopupMenuItem(
                        value: CompanyFunction.roleSettings,
                        child: Text("角色设置"),
                      ),
                      PopupMenuItem(
                        value: CompanyFunction.addUser,
                        child: Text("邀请成员"),
                      ),
                      PopupMenuItem(
                        value: CompanyFunction.addGroup,
                        child: Text("加入集团"),
                      ),
                    ],
                    onSelected: (CompanyFunction function) {
                      controller.companyOperation(function);
                    },
                   )
              ],
            ),
            body(),
          ],
        ),
      ),
    );
  }

  Widget info() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "集团信息",
            style: TextStyle(fontSize: 21.sp),
          ),
          CommonWidget.commonTextContentWidget(
              "集团名称", state.group.target.team?.name ?? ""),
          CommonWidget.commonTextContentWidget(
              "集团代码", state.group.target.code ?? ""),
          CommonWidget.commonTextContentWidget("团队简称", state.group.name ?? ""),
          CommonWidget.commonTextContentWidget(
              "团队标识", state.group.target.team?.code ?? ""),
          CommonWidget.commonTextContentWidget(
              "创建人", findTargetShare(state.group.target.team?.createUser??"").name),
          CommonWidget.commonTextContentWidget(
              "创建时间",
              DateTime.tryParse(state.group.target.team?.createTime ?? "")!
                  .format()),
          CommonWidget.commonTextContentWidget(
              "简介", state.group.target.team?.remark ?? ""),
        ],
      ),
    );
  }

  Widget body(){
    return  Obx(() {
      if(state.index.value == 1){
       return Container();
      }
      List<List<String>> content = [];
      for (var user in state.unitMember) {
        content.add([
          user.name,
          user.code,
          user.team?.name ?? "",
          user.team?.code ?? "",
          user.team?.remark ?? ""
        ]);
      }
      return CommonWidget.commonDocumentWidget(
          title: outGroupTitle,
          content: content,
          showOperation: true,
          popupMenus: [
            const PopupMenuItem(value: 'out', child: Text("移除单位")),
          ],
          onOperation: (type,data) {
            controller.removeMember(data);
          });
    });
  }
}
