import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:orginone/model/asset_creation_config.dart';
import 'package:orginone/pages/other/assets_config.dart';
import 'package:orginone/util/production_order_utils.dart';
import 'package:orginone/widget/common_widget.dart';

typedef MappingComponentsCallback = Widget Function(Fields data, {bool isEdit, AssetsType? assetsType});

Map<String, MappingComponentsCallback> testMappingComponents = {
  "text": mappingTextWidget,
  "input": mappingInputWidget,
  "select": mappingSelectBoxWidget,
  "router": mappingRouteWidget,
};


MappingComponentsCallback mappingTextWidget = (Fields data,
    {bool isEdit = false, AssetsType? assetsType}) {
  if (data.isBillCode && !isEdit) {
    ProductionOrderUtils.productionSingleOrder(assetsType!.billHeader).then((
        value) {
      data.defaultData.value = value;
    });
  }
  if(data.hidden??false){
    return Container();
  }
  return Obx(() {
    return Container(
      margin: EdgeInsets.only(
          left: (data.marginLeft ?? 0).h,
          right: (data.marginRight ?? 0).h,
          top: (data.marginTop ?? 0).h,
          bottom: (data.marginBottom ?? 0).h),
      child: CommonWidget.commonTextTile(
          data.title ?? "", data.defaultData.value ?? "",
          required: data.required ?? false,enabled: !(data.readOnly??false),showLine: true),);
  });
};

MappingComponentsCallback mappingInputWidget = (Fields data,
    {bool isEdit = false, AssetsType? assetsType}) {
  List<TextInputFormatter>? inputFormatters;
  TextEditingController controller = TextEditingController(text: data.defaultData.value?.toString()??"");
  if (data.regx != null) {
    inputFormatters = [
      FilteringTextInputFormatter.allow(RegExp(data.regx!)),
    ];
  }
  if(data.hidden??false){
    return Container();
  }
  return Container(
    margin: EdgeInsets.only(
        left: (data.marginLeft ?? 0).h,
        right: (data.marginRight ?? 0).h,
        top: (data.marginTop ?? 0).h,
        bottom: (data.marginBottom ?? 0).h),
    child: CommonWidget.commonTextTile(data.title ?? "", "",
        hint: data.hint,
        maxLine: data.maxLine,
        controller: controller,
        onChanged: (str){
          data.defaultData.value = str;
        },
        required: data.required ?? false,
        inputFormatters: inputFormatters,enabled: !(data.readOnly??false),showLine: true),
  );
};

MappingComponentsCallback mappingSelectBoxWidget = (Fields data,
    {bool isEdit = false, AssetsType? assetsType}) {
  if(data.hidden??false){
    return Container();
  }
  return Obx(() {
    String content = '';
    if(data.code?.contains("DATE")??false){
      content = data.defaultData.value??"";
    }else{
      content = data.defaultData.value?.values?.first.toString() ?? "";
    }
    return Container(
      margin: EdgeInsets.only(
          left: (data.marginLeft ?? 0).h,
          right: (data.marginRight ?? 0).h,
          top: (data.marginTop ?? 0).h,
          bottom: (data.marginBottom ?? 0).h),
      child: CommonWidget.commonChoiceTile(
          data.title ?? "",content,
          onTap: data.function,
          showLine: true,
          required: data.required ?? false),
    );
  });
};


MappingComponentsCallback mappingRouteWidget = (Fields data,
    {bool isEdit = false, AssetsType? assetsType}) {
  if(data.hidden??false){
    return Container();
  }
  return Obx(() {
    return CommonWidget.commonChoiceTile(
        data.title??"", data.defaultData.value?.name ?? "",
        required: true, onTap: data.function, showLine: true);
  });
};
