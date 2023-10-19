import 'package:doctro/AddLocation.dart';
import 'package:doctro/Addtocart.dart';
import 'package:doctro/AllPharamacy.dart';
import 'package:doctro/Book_success.dart';
import 'package:doctro/Bookappointment.dart';
import 'package:doctro/Favoritedoctor.dart';
import 'package:doctro/HealthTips.dart';
import 'package:doctro/HealthTipsDetail.dart';
import 'package:doctro/Home.dart';
import 'package:doctro/MedicineDescription.dart';
import 'package:doctro/Offer.dart';
import 'package:doctro/PharamacyDetail.dart';
import 'package:doctro/Review_Appointment.dart';
import 'package:doctro/Setting.dart';
import 'package:doctro/SignIn.dart';
import 'package:doctro/Specialist.dart';
import 'package:doctro/Treatment.dart';
import 'package:doctro/TreatmentSpecialist.dart';
import 'package:doctro/const/preference.dart';
import 'package:doctro/doctordetail.dart';
import 'package:doctro/forgotpassword.dart';
import 'package:doctro/Showlocation.dart';
import 'package:doctro/phoneverification.dart';
import 'package:doctro/profile.dart';
import 'package:doctro/signup.dart';
import 'package:doctro/Myprescription.dart';
import 'package:doctro/Appointment.dart';
import 'package:doctro/ChangeLanguage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctro/ChangePassword.dart';
import 'package:doctro/MedicineOrder.dart';
import 'package:doctro/MedicineOrderDetail.dart';
import 'package:doctro/MedicinePayment.dart';
import 'package:doctro/StripePaymentScreen.dart';
import 'package:doctro/StripePaymentScreenMedicine.dart';
import 'package:doctro/notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'AboutUs.dart';
import 'PrivacyPolicy.dart';
import 'const/Palette.dart';
import 'localization/language_localization.dart';
import 'localization/localization_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
          setState(() {
            this._locale = local;
          })
        });
    super.didChangeDependencies();
  }

  getPermission() async {
    if (await Permission.location.isRestricted) {
      Permission.location.request();
      if (await Permission.location.isRestricted || await Permission.location.isDenied) {
        Permission.location.request();
      }
    }
    if (await Permission.storage.isDenied) {
      Permission.storage.request();
      if (await Permission.storage.isDenied || await Permission.storage.isDenied) {
        Permission.storage.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return MaterialApp(
        title: 'Doctro',
        locale: _locale,
        supportedLocales: [
          Locale(ENGLISH, 'US'),
          Locale(SPANISH, 'ES'),
          Locale(ARABIC, 'AE'),
        ],
        localizationsDelegates: [
          LanguageLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocal, supportedLocales) {
          for (var local in supportedLocales) {
            if (local.languageCode == deviceLocal!.languageCode &&
                local.countryCode == deviceLocal.countryCode) {
              return deviceLocal;
            }
          }
          return supportedLocales.first;
        },

        debugShowCheckedModeBanner: false,
        // home: Home(),
        initialRoute: "/",
        theme: ThemeData(
          splashColor: Palette.transparent,
          highlightColor: Palette.transparent,
        ),
        routes: {
          '/':(context) => Home(),
          'SignIn': (context) => SignIn(),
          'signup': (context) => signup(),
          'forgotpassword': (context) => forgotpassword(),
          'phoneverification': (context) => phoneverification(0),
          'Home': (context) => Home(),
          'Treatment': (context) => Treatment(),
          'Favoritedoctor': (context) => Favoritedoctor(),
          'Specialist': (context) => Specialist(),
          'Doctordetail': (context) => Doctordetail(0),
          'Bookappointment': (context) => Bookappointment(0),
          'Appointment': (context) => Appointment(),
          'Myprescription': (context) => Myprescription(),
          'HealthTips': (context) => HealthTips(),
          'HealthTipsDetail': (context) => HealthTipsDetail(0),
          'Setting': (context) => Setting(),
          'Addtocart': (context) => Addtocart(),
          'Offer': (context) => Offer(),
          'profile': (context) => profile(),
          'ShowLocation': (context) => ShowLocation(),
          'AddLocation': (context) => AddLocation(),
          'BookSuccess': (context) => BookSuccess(),
          'Review': (context) => Review(),
          'MedicineDescription': (context) => MedicineDescription(0),
          'AllPharamacy': (context) => AllPharamacy(),
          'PharamacyDetail': (context) => PharamacyDetail(0),
          'MadicinePayment': (context) => MadicinePayment(),
          'MedicineOrder': (context) => MedicineOrder(),
          'MedicineOrderDetail': (context) => MedicineOrderDetail(),
          'TreatmentSpecialist': (context) => TreatmentSpecialist(0),
          'notifications': (context) => notifications(),
          'StripePaymentScreen': (context) => StripePaymentScreen(),
          'StripePaymentScreenMedicine': (context) => StripePaymentScreenMedicine(),
          'ChangePassword': (context) => ChangePassword(),
          'PrivacyPolicy': (context) => PrivacyPolicy(),
          'AboutUs': (context) => AboutUs(),
          'ChangeLanguage': (context) => ChangeLanguage(),
        },
      );
    }
  }
}
