import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:orginone/api_resp/org_chat_cache.dart';
import 'package:orginone/api_resp/space_messages_resp.dart';
import 'package:orginone/api_resp/target_resp.dart';
import 'package:orginone/page/home/home_controller.dart';
import 'package:orginone/page/home/message/component/message_item_widget.dart';
import 'package:orginone/util/any_store_util.dart';
import 'package:orginone/util/encryption_util.dart';
import 'package:orginone/util/hive_util.dart';
import 'package:orginone/util/notification_util.dart';

import '../../../api_resp/message_detail_resp.dart';
import '../../../api_resp/message_item_resp.dart';
import '../../../enumeration/message_type.dart';
import '../../../enumeration/target_type.dart';
import '../../../util/hub_util.dart';
import 'chat/chat_controller.dart';

/// 所有与后端消息交互的逻辑都先保存至数据库中再读取出来
class MessageController extends GetxController with WidgetsBindingObserver {
  // 日志对象
  Logger log = Logger("MessageController");

  // 参数
  OrgChatCache orgChatCache = OrgChatCache.empty();

  // 会话索引
  Map<String, SpaceMessagesResp> spaceMap = {};
  Map<String, Map<String, MessageItemResp>> spaceMessageItemMap = {};

  // 当前 app 状态
  AppLifecycleState? currentAppState;

  @override
  void onInit() async {
    super.onInit();
    // 监听页面的生命周期
    WidgetsBinding.instance.addObserver(this);
    // 订阅聊天面板信息
    await _subscribingCharts();
  }

  // 分组排序
  sortingGroups() {
    HomeController homeController = Get.find<HomeController>();
    List<SpaceMessagesResp> groups = orgChatCache.chats;
    List<SpaceMessagesResp> spaces = [];
    SpaceMessagesResp? topping;
    for (SpaceMessagesResp space in groups) {
      var isCurrent = space.id == homeController.currentSpace.id;
      if (space.id == "topping") {
        topping = space;
        space.isExpand = true;
      } else if (isCurrent) {
        space.isExpand = isCurrent;
        spaces.insert(0, space);
      } else {
        space.isExpand = false;
        spaces.add(space);
      }
    }
    if (topping != null) {
      spaces.insert(0, topping);
    }
    orgChatCache.chats = spaces;
  }

  // 组内会话排序
  sortingItems(SpaceMessagesResp spaceMessagesResp) {
    // 会话
    spaceMessagesResp.chats.sort((first, second) {
      if (first.msgTime == null || second.msgTime == null) {
        return 0;
      } else {
        return -first.msgTime!.compareTo(second.msgTime!);
      }
    });
  }

  Future<dynamic> refreshCharts() async {
    // 读取聊天群
    List<SpaceMessagesResp> messageGroups = await HubUtil().getChats();

    // 处理空间并排序
    orgChatCache.chats = _spaceHandling(messageGroups);
    sortingGroups();
    update();

    // 缓存消息
    await HubUtil().cacheChats(orgChatCache);
  }

  /// 订阅聊天群变动
  _subscribingCharts() async {
    SubscriptionKey key = SubscriptionKey.orgChat;
    String domain = Domain.user.name;
    await AnyStoreUtil().subscribing(key, domain, _updateChats);
    if (orgChatCache.chats.isEmpty) {
      await refreshCharts();
    }
  }

  /// 从订阅通道拿到的数据直接更新试图
  _updateChats(Map<String, dynamic> data) {
    orgChatCache = OrgChatCache(data);
    orgChatCache.chats = _spaceHandling(orgChatCache.chats);
    sortingGroups();
    _latestMsgHandling(orgChatCache.messageDetail);
    update();
  }

  /// 最新的消息处理
  _latestMsgHandling(MessageDetailResp? detail) {
    if (detail == null) {
      return;
    }
    if (Get.isRegistered<ChatController>()) {
      // 消息预处理
      TargetResp userInfo = HiveUtil().getValue(Keys.userInfo);
      var sessionId = detail.toId;
      if (detail.toId == userInfo.id) {
        sessionId = detail.fromId;
      }

      ChatController chatController = Get.find<ChatController>();
      chatController.onReceiveMsg(detail.spaceId!, sessionId, detail);
    }
  }

  /// 空间处理
  List<SpaceMessagesResp> _spaceHandling(List<SpaceMessagesResp> groups) {
    // 新的数组
    List<SpaceMessagesResp> spaces = [];
    Map<String, SpaceMessagesResp> newSpaceMap = {};
    Map<String, Map<String, MessageItemResp>> newSpaceMessageItemMap = {};

    // 置顶会话
    groups = groups.where((item) => item.id != "topping").toList();
    SpaceMessagesResp topGroup = SpaceMessagesResp("topping", "置顶会话", []);

    bool hasTop = false;
    for (var group in groups) {
      // 初始数据
      String spaceId = group.id;
      List<MessageItemResp> chats = group.chats;

      // 建立索引
      newSpaceMap[spaceId] = group;
      newSpaceMessageItemMap[spaceId] = {};

      // 数据映射
      for (MessageItemResp messageItem in chats) {
        var id = messageItem.id;
        if (spaceMessageItemMap.containsKey(spaceId)) {
          var messageItemMap = spaceMessageItemMap[spaceId]!;
          if (messageItemMap.containsKey(id)) {
            var oldItem = messageItemMap[id]!;
            messageItem.msgTime = oldItem.msgTime;
            messageItem.msgType ??= oldItem.msgType;
            messageItem.msgBody ??= oldItem.msgBody;
            messageItem.personNum ??= oldItem.personNum;
            messageItem.noRead ??= oldItem.noRead;
            messageItem.showTxt ??= oldItem.showTxt;
            messageItem.isTop ??= oldItem.isTop;
          }
        }
        newSpaceMessageItemMap[spaceId]![id] = messageItem;
        if (messageItem.isTop == true) {
          hasTop = true;
        }
      }

      // 组内排序
      sortingItems(group);
      spaces.add(group);
    }
    if (hasTop) {
      spaces.insert(0, topGroup);
    }
    spaceMap = newSpaceMap;
    spaceMessageItemMap = newSpaceMessageItemMap;
    return spaces;
  }

  /// 接受消息
  Future<void> onReceiveMessage(List<dynamic> messageList) async {
    if (messageList.isEmpty) {
      return;
    }
    TargetResp userInfo = HiveUtil().getValue(Keys.userInfo);

    for (var message in messageList) {
      log.info("接收到一条新的消息$message");
      var detail = MessageDetailResp.fromMap(message);

      try {
        // 会话 ID
        var sessionId = detail.toId;
        if (detail.toId == userInfo.id) {
          sessionId = detail.fromId;
        }

        // 确定会话
        MessageItemResp? currentItem =
            spaceMessageItemMap[detail.spaceId]?[sessionId];
        outer:
        for (var space in orgChatCache.chats) {
          for (var item in space.chats) {
            if (item.id == sessionId) {
              currentItem = item;
            }
            if (item.typeName == TargetType.person.name &&
                currentItem != null &&
                detail.spaceId != item.spaceId) {
              currentItem = null;
            }
            if (currentItem != null) {
              break outer;
            }
          }
        }
        if (currentItem == null) {
          throw Exception("未找到会话!");
        }

        if (detail.msgType == MessageType.topping.name) {
          currentItem.isTop = bool.fromEnvironment(detail.msgBody ?? "false");
        } else {
          if (detail.spaceId == userInfo.id) {
            // 如果是个人空间，存储一下信息
            await HubUtil().cacheMsg(sessionId, detail);
          }
          detail.msgBody = EncryptionUtil.inflate(detail.msgBody ?? "");
          String? msgBody = detail.msgBody;
          currentItem.msgBody = msgBody;
          currentItem.msgTime = detail.createTime;
          currentItem.msgType = detail.msgType;
          if (currentItem.msgType == MessageType.recall.name) {
            bool hasPic = msgBody?.contains("<img>") ?? false;
            currentItem.showTxt = hasPic ? "[图片]" : msgBody;
          } else {
            currentItem.showTxt = msgBody;
          }
          if (currentItem.typeName != TargetType.person.name) {
            String name = orgChatCache.nameMap[detail.fromId];
            currentItem.showTxt = "$name：${currentItem.showTxt}";
          }

          if (Get.isRegistered<ChatController>()) {
            ChatController chatController = Get.find();
            chatController.onReceiveMsg(detail.spaceId!, sessionId, detail);
          }
          bool isTalking = false;
          for (MessageItemResp openItem in orgChatCache.openChats) {
            if (openItem.id == currentItem.id &&
                openItem.spaceId == currentItem.spaceId) {
              isTalking = true;
            }
          }
          if (!isTalking && detail.fromId != userInfo.id) {
            // 不在会话中且不是我发的消息
            currentItem.noRead = (currentItem.noRead ?? 0) + 1;
          }
          // 如果正在后台，发送本地消息提示
          _pushMessage(currentItem, detail);
          orgChatCache.messageDetail = detail;
          orgChatCache.target = currentItem;
          for (var group in orgChatCache.chats) {
            sortingItems(group);
          }
        }

        // 更新试图
        update();

        // 缓存会话
        HubUtil().cacheChats(orgChatCache);
      } catch (error) {
        log.info("接收消息异常:$error");
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    currentAppState = state;
  }

  void _pushMessage(MessageItemResp item, MessageDetailResp detail) {
    TargetResp userInfo = HiveUtil().getValue(Keys.userInfo);
    if (currentAppState != null &&
        currentAppState == AppLifecycleState.paused &&
        detail.fromId != userInfo.id) {
      // 当前系统在后台，且不是自己发的消息
      NotificationUtil.showNewMsg(item.name, item.showTxt ?? "");
    }
  }

  funcCallback(LongPressFunc func, String spaceId, MessageItemResp item) async {
    switch (func) {
      case LongPressFunc.topping:
      case LongPressFunc.cancelTopping:
        item.isTop = func == LongPressFunc.topping;
        orgChatCache.chats = _spaceHandling(orgChatCache.chats);
        sortingGroups();
        await HubUtil().cacheChats(orgChatCache);
        update();
        break;
    }
  }
}
