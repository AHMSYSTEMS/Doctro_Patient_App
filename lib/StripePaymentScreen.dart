import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'api/Retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';
import 'model/bookappointments.dart';

class StripePaymentScreen extends StatefulWidget {
  String? selectAppointmentFor;
  String? patientName;
  String? illnessInformation;
  String? age;
  String? patientAddress;
  String? phoneNo;
  String? selectDrugEffects;
  String? note;
  String? newDate; // pass Api
  String? selectTime;
  String? appointmentFees;
  int? doctorId;
  String? newDateUser; // show user
  List<String>? reportImages;

  StripePaymentScreen({
    this.selectAppointmentFor,
    this.patientName,
    this.illnessInformation,
    this.age,
    this.patientAddress,
    this.phoneNo,
    this.selectDrugEffects,
    this.note,
    this.newDate,
    this.selectTime,
    this.appointmentFees,
    this.doctorId,
    this.newDateUser,
    this.reportImages,
  });

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late var str;
  var parts;
  var year;
  var date;

  var _error;
  var _paymentToken;

  String? pass_BookDate = "";
  String? pass_BookTime = "";
  String pass_BookID = "";

  String? Booking_Id = "";

  String Payment_Token = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: SharedPreferenceHelper.getString(Preferences.stripe_public_key),
        merchantId: "Test",
        androidPayMode: 'test',
      ),
    );
  }

  _pass_DateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        pass_BookDate = widget.newDateUser;
        pass_BookTime = widget.selectTime;
        pass_BookID = '$Booking_Id';
        prefs.setString('BookDate', pass_BookDate!);
        prefs.setString('BookTime', pass_BookTime!);
        prefs.setString('BookID', pass_BookID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cardBgColor:  Palette.blue,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor:  Palette.blue,
                      cardNumberDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expired Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Holder',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary:  Palette.blue,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child:  Text(
                          getTranslated(context, stripePaymentBookAppointment_pay).toString(),
                          // 'PAY',
                          style: TextStyle(
                            color:  Palette.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          str = "$expiryDate";
                          parts = str.split("/");
                          date = parts[0].trim();
                          year = parts.sublist(1).join('/').trim();

                          int exMoth = int.parse(date.toString());
                          int exyear = int.parse(year.toString());

                          CreditCard testCard = CreditCard(
                            number: cardNumber,
                            expMonth: exMoth,
                            expYear: exyear,
                          );

                          await StripePayment.createTokenWithCard(
                            testCard,
                          ).then(
                            (token) {
                              Payment_Token = "${token.tokenId}";
                              Payment_Token != "" && Payment_Token.isNotEmpty
                                  ? CallApiBook()
                                  : Fluttertoast.showToast(
                                      msg: getTranslated(context, stripePaymentBookAppointment_paymentNotComplete_toast).toString(),
                                      // "Payment Not Complete",
                                  toastLength: Toast.LENGTH_SHORT);
                              setState(
                                () {
                                  _paymentToken = token;
                                },
                              );
                            },
                          ).catchError(setError);

                          StripePayment.createTokenWithCard(
                            testCard,
                          )
                              .then(
                                (token) {},
                              )
                              .catchError(setError);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void setError(dynamic error) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }


  Future<BaseModel<Bookappointments>> CallApiBook() async {
    Bookappointments response;
    Map<String, dynamic> body = {
      "appointment_for": widget.selectAppointmentFor,
      "patient_name": widget.patientName,
      "illness_information": widget.illnessInformation,
      "age": widget.age,
      "patient_address": widget.patientAddress,
      "phone_no": widget.phoneNo,
      "drug_effect": widget.selectDrugEffects,
      "note": widget.note,
      "date": widget.newDate,
      "time": widget.selectTime,
      "payment_type": "Stripe",
      "payment_status": 1,
      "payment_token": Payment_Token,
      "amount": widget.appointmentFees,
      "doctor_id": widget.doctorId,
      "report_image": widget.reportImages!.length != 0 ? widget.reportImages : "",
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(Retro_Api().Dio_Data()).bookappointment(body);
      if (response.success == true) {
        setState(
              () {
            Preferences.hideDialog(context);
            Booking_Id = response.data;
            _pass_DateTime();
            Navigator.pushReplacementNamed(context, 'BookSuccess');
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          },
        );
      } else {
        Preferences.hideDialog(context);
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
