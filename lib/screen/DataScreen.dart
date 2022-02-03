import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:musicnako/Network/NetworkUtils.dart';
import 'package:musicnako/app_localizations.dart';
import 'package:musicnako/component/DeepLinkWidget.dart';
import 'package:musicnako/main.dart';
import 'package:musicnako/model/MainResponse.dart';
import 'package:musicnako/screen/DashboardScreen.dart';
import 'package:musicnako/screen/ErrorScreen.dart';
import 'package:musicnako/screen/SplashScreen.dart';
import 'package:musicnako/utils/bloc.dart';
import 'package:musicnako/utils/constant.dart';
import 'package:musicnako/utils/loader.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class DataScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  DataScreenState createState() => DataScreenState();
}

class DataScreenState extends State<DataScreen> with AfterLayoutMixin<DataScreen> {
  bool isWasConnectionLoss = false;
  AsyncMemoizer<MainResponse> mainMemoizer = AsyncMemoizer<MainResponse>();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
//
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (isMobile) {
      OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) async {
        String? urlString = await notification.notification.additionalData!["ID"];

        if (urlString.validate().isNotEmpty) {
          toast(urlString);
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    DeepLinkBloc _bloc = DeepLinkBloc();
    return Scaffold(
      body: Stack(
        children: [
          Provider<DeepLinkBloc>(
            create: (context) => _bloc,
            dispose: (context, bloc) => bloc.dispose(),
            child: DeepLinkWidget(),
          ),
          FutureBuilder<MainResponse>(
            future: mainMemoizer.runOnce(() => fetchData()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.toJson().isNotEmpty) {
                  if (snapshot.data!.appconfiguration!.isSplashScreen == "true")
                    return SplashScreen();
                  else
                    return SafeArea(
                      child: DashBoardScreen(),
                    );
                } else {
                  return ErrorScreen(error: appLocalization.translate('msg_add_configuration'));
                }
              } else if (snapshot.hasError) {
                if (PURCHASE_CODE.isNotEmpty) {
                  return ErrorScreen(error: (appLocalization.translate('msg_wrong_url')!) + " " + (appLocalization.translate('lbl_or')!) + " " + appLocalization.translate('msg_add_configuration')!);
                } else {
                  return ErrorScreen(error: appLocalization.translate('msg_wrong_url'));
                }
              }
              return Loaders(name: appStore.loaderValues).center();
            },
          ),
        ],
      ),
    );
  }
}
