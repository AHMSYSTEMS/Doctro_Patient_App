import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:dio/dio.dart';
import '../const/prefConstatnt.dart';
import '../const/preference.dart';
import '../database/db_service.dart';
import '../models/data_model.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';

class StripePaymentScreenMedicine extends StatefulWidget {
  int? pharamacyId;
  String? amount;
  String? deliveryType;
  String? prescriptionFilePath;
  String? strFinalDeliveryCharge;
  List<Map>? listData;

  StripePaymentScreenMedicine({
    this.pharamacyId,
    this.amount,
    this.deliveryType,
    this.strFinalDeliveryCharge,
    this.listData,
    this.prescriptionFilePath,
  });

  @override
  _StripePaymentScreenMedicineState createState() => _StripePaymentScreenMedicineState();
}

class _StripePaymentScreenMedicineState extends State<StripePaymentScreenMedicine> {
  bool loading = false;

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

  String pass_BookDate = "";
  String pass_BookTime = "";
  String pass_BookID = "";

  String Booking_Id = "";

  String Payment_Token = "";
  ProductModel? model;
  late DBService dbService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbService = new DBService();
    model = new ProductModel();
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: SharedPreferenceHelper.getString(Preferences.stripe_public_key),
        merchantId: "Test",
        androidPayMode: 'test',
      ),
    );
    _getAddress();
  }

  String? address = "";
  int addressId = 0;

  String isWhere = "";
  String? userLat = "";
  String? userLang = "";
  String? user_phoneno = "";
  String? user_email = "";

  _getAddress() async {
    setState(
      () {
        address = (SharedPreferenceHelper.getString('Address'));
        addressId = (SharedPreferenceHelper.getInt('addressId'));
        userLat = SharedPreferenceHelper.getString('lat');
        userLang = SharedPreferenceHelper.getString('lang');
        //user data
        user_phoneno = SharedPreferenceHelper.getString('phone_no');
        user_email = SharedPreferenceHelper.getString('email');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 1,
      progressIndicator: SpinKitFadingCircle(
        color:  Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
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
                            getTranslated(context, stripePaymentMedicineBook_pay).toString(),
                            // 'Pay',
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
                                    ? callApiBookMedicine()
                                    : Fluttertoast.showToast(
                                        msg:  getTranslated(context, stripePaymentBookAppointment_paymentNotComplete_toast).toString(),
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
                            ).then((token) {}).catchError(setError);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    print('my stripe error is $error');
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  Future<String> callApiBookMedicine() async {
    Dio dio = Dio();
    String? t = SharedPreferenceHelper.getString(Preferences.auth_token);
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.headers["Content-Type"] = "multipart/form-data"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 3000;
    if (t != "N/A") {
      dio.options.headers["Authorization"] = "Bearer " + t!;
    }
    String fileName = widget.prescriptionFilePath!.split('/').last;
    print('file name ${fileName}');
    FormData formData;

    if (widget.prescriptionFilePath == "") {
      formData = FormData.fromMap({
        "pharmacy_id": widget.pharamacyId,
        "medicines": JsonEncoder().convert(widget.listData),
        "amount": widget.amount,
        "payment_type": "Stripe",
        "payment_status": 1,
        "payment_token": Payment_Token,
        "shipping_at": widget.deliveryType,
        "address_id": widget.deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": widget.deliveryType == 'Pharmacy' ? 0 : widget.strFinalDeliveryCharge,
      });
    } else {
      formData = FormData.fromMap({
        "pdf": MultipartFile.fromFileSync(widget.prescriptionFilePath!, filename: fileName),
        "pharmacy_id": widget.pharamacyId,
        "medicines": JsonEncoder().convert(widget.listData),
        "amount": widget.amount,
        "payment_type": "Stripe",
        "payment_status": 1,
        "payment_token": Payment_Token,
        "shipping_at": widget.deliveryType,
        "address_id": widget.deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": widget.deliveryType == 'Pharmacy' ? 0 : widget.strFinalDeliveryCharge,
      });
    }

    setState(() {
      Preferences.onLoading(context);
    });
    try {
      var response =
          await dio.post("${Preferences.base_url}book_medicine", data: formData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Preferences.hideDialog(context);
      print('Ready');
      prefs.remove('grandTotal');
      prefs.remove('strFinalDeliveryCharge');
      prefs.remove('pharmacyId');
      prefs.remove('prescriptionFilePath');
      late List<ProductModel> products;
      await dbService.getProducts().then((value) {
        products = value;
      });
      dbService.deleteTable(products[0]).then((value) {
        setState(() {});
      });
      var decodeData = json.decode(response.toString());
      Fluttertoast.showToast(
        msg: '${decodeData['msg']}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pushReplacementNamed(context, 'AllPharamacy');
      print('12234545  ${response.toString()}');
    } catch (e) {
      print('12345ERROR   ${e.toString()}');
      Preferences.hideDialog(context);
      Fluttertoast.showToast(
        msg: getTranslated(context, stripePaymentMedicineBook_bookingFailed_toast).toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return "";
  }
}
