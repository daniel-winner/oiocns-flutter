

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:orginone/dart/base/schema.dart';
import 'package:orginone/dart/core/getx/base_get_state.dart';
import 'package:orginone/dart/core/thing/species.dart';

class ClassificationInfoState extends BaseGetState{
  late SpeciesItem species;
  late TabController tabController;

  var dict = <XDict>[].obs;
  ClassificationInfoState(){
    species = Get.arguments['species'];
  }
}

const List<String> tabTitle = ["基本信息", "分类特性", "字典定义"];