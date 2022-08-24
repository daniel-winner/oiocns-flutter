import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:orginone/page/home/czhtest/czh_binding.dart';
import 'package:orginone/page/home/czhtest/czh_page.dart';
import 'package:orginone/page/home/home_binding.dart';
import 'package:orginone/page/home/home_page.dart';
import 'package:orginone/page/home/message/chat/chat_binding.dart';
import 'package:orginone/page/home/message/chat/chat_page.dart';
import 'package:orginone/page/home/message/message_binding.dart';
import 'package:orginone/page/home/message/message_page.dart';
import 'package:orginone/page/login/login_binding.dart';
import 'package:orginone/page/login/login_page.dart';
import 'package:orginone/page/register/register_binding.dart';
import 'package:orginone/page/register/register_page.dart';

class Routers {
  static const String main = "/";
  static const String register = "/register";
  static const String login = "/login";
  static const String home = "/home";
  static const String message = "/message";
  static const String chat = "/chat";
  static const String czh = "/czh";

  static List<GetPage> getInitRouters() {
    return [
      GetPage(
          name: Routers.main,
          page: () => const LoginPage(),
          binding: LoginBinding()),
      GetPage(
          name: Routers.register,
          page: () => const RegisterPage(),
          binding: RegisterBinding()),
      GetPage(
          name: Routers.login,
          page: () => const LoginPage(),
          binding: LoginBinding()),
      GetPage(
          name: Routers.home,
          page: () => const HomePage(),
          binding: HomeBinding()),
      GetPage(
        name: Routers.message,
        page: () => const MessagePage(),
        binding: MessageBinding(),
      ),
      GetPage(
        name: Routers.chat,
        page: () => const ChatPage(),
        binding: ChatBinding(),
      ),
      GetPage(
        name: Routers.czh,
        page: () => const CzhPage(),
        binding: CzhPageBinding(),
      )
    ];
  }
}
