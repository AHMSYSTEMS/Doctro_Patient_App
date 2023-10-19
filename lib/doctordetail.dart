import 'dart:convert';
import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/Bookappointment.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/const/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'database/form_helper.dart';
import 'localization/localization_constant.dart';
import 'model/Docterdetail.dart';

class Doctordetail extends StatefulWidget {
  int? id;

  Doctordetail(int? id) {
    this.id = id;
  }

  @override
  _DoctordetailState createState() => _DoctordetailState(id);
}

class _DoctordetailState extends State<Doctordetail> with TickerProviderStateMixin {
  bool _loadding = false;

  List<Tab> tabList = [];
  TabController? _tabController;

  int? id = 0;
  String? name = "";
  String? expertise = "";
  String? appointmentFees = "";
  String? experience = "";
  dynamic rate = 0.0;
  String? desc = "";
  String education = "";
  String certificate = "";
  String? fullImage = "";
  String? treatmentname = "";

  String? mobileNo = "";

  List<String?> degree = [];
  List<String?> collage = [];
  List<String?> de_year = [];

  List<String?> award = [];
  List<String?> ce_year = [];

  List<Hosiptal> hosiptaldetail = [];
  List<HospitalGallery> hosiptalGallery = [];

  List<Reviews> reviews = [];

  _DoctordetailState(int? id) {
    this.id = id;
  }

  void initState() {
    Future.delayed(Duration.zero, () {
      tabList.add(
        new Tab(
          child: Text(
            getTranslated(context, doctorDetail_tab1_title).toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
      tabList.add(
        new Tab(
          child: Text(
            getTranslated(context, doctorDetail_tab2_title).toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
      tabList.add(
        new Tab(
          child: Text(
            getTranslated(context, doctorDetail_tab3_title).toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );
      _tabController = new TabController(vsync: this, length: tabList.length);
      _doctordetail();
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Palette.dark_blue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Palette.white,
        title: Text(
          getTranslated(context, doctorDetail_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loadding,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: Container(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: height * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launch("tel:$mobileNo");
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  'assets/icons/call.svg',
                                ),
                              ),
                            ),
                            Container(
                              width: width * 0.3,
                              height: width * 0.3,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                imageUrl: '$fullImage',
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Palette.blue,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    // CircularProgressIndicator(),
                                    SpinKitFadingCircle(color: Palette.blue),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/images/no_image.jpg"),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                launch("sms:$mobileNo");
                              },
                              child: Container(
                                child: SvgPicture.asset(
                                  'assets/icons/msg.svg',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: width * 0.05),
                        child: Text(
                          '$name',
                          style: TextStyle(
                            fontSize: width * 0.05,
                            color: Palette.blue,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: width * 0.01),
                        child: Text(
                          '$treatmentname',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: Palette.grey,
                          ),
                        ),
                      ),
                      Container(
                        // height: 150,
                        margin: EdgeInsets.only(top: height * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                  child: Text(
                                    getTranslated(context, doctorDetail_appointmentFees).toString(),
                                    style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$appointmentFees',
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                  child: Text(
                                    getTranslated(context, doctorDetail_doctorExperience)
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Palette.dark_blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    '$experience  ' +
                                        getTranslated(context, doctorDetail_year).toString(),
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: width * 0.005),
                                    child: Text(
                                      getTranslated(context, doctorDetail_doctorRates).toString(),
                                      style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Palette.dark_blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/hart.svg',
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: width * 0.028, right: width * 0.028),
                                        child: Text(
                                          '$rate',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: new Container(
                  height: size.height * 0.05,
                  color: Palette.dark_white,
                  padding: EdgeInsets.all(width * 0.02),
                  child: new TabBar(
                    labelColor: Palette.blue,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.transparent,
                    tabs: tabList,
                    unselectedLabelColor: Palette.dark_blue,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: new Container(
                  child: new TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: size.height * 0.02,
                                    right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  getTranslated(context, doctorDetail_personalBio).toString(),
                                  style:
                                      TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.05, top: height * 0.01, right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  '$desc',
                                  style: TextStyle(fontSize: 13, color: Palette.grey),
                                  textAlign: TextAlign.justify,
                                  maxLines: 4,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: size.height * 0.02,
                                    right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  getTranslated(context, doctorDetail_education).toString(),
                                  style:
                                      TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: degree.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05, top: width * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          degree[index]!.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.dark_blue),
                                        ),
                                      ),
                                      Container(
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          collage[index]! + '.',
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                        ),
                                      ),
                                      Container(
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          de_year[index]!,
                                          style: TextStyle(
                                            fontSize: width * 0.03,
                                            color: Palette.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: size.height * 0.02,
                                    right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  getTranslated(context, doctorDetail_certificate).toString(),
                                  style:
                                      TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: award.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05, top: width * 0.02, right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Container(
                                          child: Text(
                                            award[index]!,
                                            style: TextStyle(
                                                fontSize: width * 0.03, color: Palette.dark_blue),
                                          ),
                                        ),
                                        Text(
                                          '.  ' + ce_year[index]!,
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: width * 0.05,
                                    top: size.height * 0.02,
                                    right: width * 0.05),
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  getTranslated(context, doctorDetail_specialization).toString(),
                                  // "Specialization",
                                  style:
                                      TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                ),
                              ),
                            ),
                            Center(
                                child: Container(
                              margin: EdgeInsets.only(
                                  left: width * 0.05, top: size.height * 0.01, right: width * 0.05),
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                '$expertise',
                                style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                              ),
                            )),
                          ],
                        ),
                      ),

                      //tab 2
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: hosiptaldetail.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      top: size.height * 0.02,
                                      right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, doctorDetail_hospitalName)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04, color: Palette.dark_blue),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          hosiptaldetail[index].name!,
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      top: size.height * 0.02,
                                      right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, doctorDetail_phoneNumber)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04, color: Palette.dark_blue),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          hosiptaldetail[index].phone!,
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      top: size.height * 0.02,
                                      right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, doctorDetail_address).toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04, color: Palette.dark_blue),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Container(
                                        width: width * 0.55,
                                        child: Text(
                                          hosiptaldetail[index].address!,
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      top: size.height * 0.02,
                                      right: width * 0.05),
                                  alignment: AlignmentDirectional.topStart,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.35,
                                        child: Text(
                                          getTranslated(context, doctorDetail_facility).toString(),
                                          style: TextStyle(
                                              fontSize: width * 0.04, color: Palette.dark_blue),
                                        ),
                                      ),
                                      Container(
                                        width: width / 3,
                                        child: Text(
                                          hosiptaldetail[index].facility!,
                                          style: TextStyle(
                                              fontSize: width * 0.03, color: Palette.grey),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      //tab 3
                      reviews.length != 0
                          ? SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: width * 0.05,
                                          top: size.height * 0.02,
                                          right: width * 0.05),
                                      alignment: AlignmentDirectional.topStart,
                                      child: Text(
                                        getTranslated(context, doctorDetail_review).toString(),
                                        style: TextStyle(
                                            fontSize: width * 0.04, color: Palette.dark_blue),
                                      ),
                                    ),
                                  ),
                                  reviews.length != 0
                                      ? ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: reviews.length,
                                          itemBuilder: (context, index) {
                                            String date = DateUtil().formattedDate(
                                                DateTime.parse(reviews[index].createdAt!));
                                            return Container(
                                              margin: EdgeInsets.only(
                                                left: width * 0.02,
                                                right: width * 0.02,
                                              ),
                                              width: width * 0.87,
                                              height: height * 0.1,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    child: ListTile(
                                                      isThreeLine: true,
                                                      leading: SizedBox(
                                                        child: Container(
                                                          height: height * 0.062,
                                                          width: width * 0.125,
                                                          decoration: new BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                new BoxShadow(
                                                                  color: Palette.blue,
                                                                  blurRadius: 1.0,
                                                                ),
                                                              ]),
                                                          child: CachedNetworkImage(
                                                            alignment: Alignment.center,
                                                            imageUrl:
                                                                reviews[index].user!.fullImage!,
                                                            imageBuilder:
                                                                (context, imageProvider) =>
                                                                    CircleAvatar(
                                                              radius: 50,
                                                              backgroundColor: Palette.white,
                                                              child: CircleAvatar(
                                                                radius: 20,
                                                                backgroundImage: imageProvider,
                                                              ),
                                                            ),
                                                            placeholder: (context, url) =>
                                                                SpinKitFadingCircle(
                                                                    color: Palette.dark_blue),
                                                            errorWidget: (context, url, error) =>
                                                                Image.asset(
                                                              "assets/images/no_image.jpg",
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      title: Column(
                                                        children: [
                                                          Container(
                                                            alignment:
                                                                AlignmentDirectional.topStart,
                                                            margin: EdgeInsets.only(
                                                              top: height * 0.01,
                                                            ),
                                                            child: Text(
                                                              reviews[index].user!.name!,
                                                              style: TextStyle(
                                                                  fontSize: width * 0.03,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment:
                                                                AlignmentDirectional.topStart,
                                                            child: Text(
                                                              '$date',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Palette.grey),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      trailing: Container(
                                                        child: RatingBarIndicator(
                                                          rating: reviews[index].rate.toDouble(),
                                                          itemBuilder: (context, index) => Icon(
                                                            Icons.star,
                                                            color: Palette.blue,
                                                          ),
                                                          itemCount: 5,
                                                          itemSize: width * 0.04,
                                                          direction: Axis.horizontal,
                                                        ),
                                                      ),
                                                      subtitle: Container(
                                                        margin: EdgeInsets.only(top: width * 0.015),
                                                        alignment: AlignmentDirectional.topStart,
                                                        child: Text(
                                                          reviews[index].review!,
                                                          style: TextStyle(
                                                              fontSize: 12, color: Palette.grey),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : SizedBox(),
                                ],
                              ))
                          : Container(
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                getTranslated(context, doctorDetail_noReview).toString(),
                                // "No Review",
                                style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: width * 0.12,
        child: ElevatedButton(
          child: Text(
            getTranslated(context, doctorDetail_bookAppointment).toString(),
            style: TextStyle(fontSize: width * 0.04, color: Palette.white),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Bookappointment(id),
                    ),
                  )
                : FormHelper.showMessage(
                    context,
                    getTranslated(context, doctorDetail_appointmentBook_alert_title).toString(),
                    getTranslated(context, doctorDetail_appointmentBook_alert_text).toString(),
                    getTranslated(context, cancel).toString(),
                    () {
                      Navigator.of(context).pop();
                    },
                    buttonText2: getTranslated(context, login).toString(),
                    // "Login",
                    isConfirmationDialog: true,
                    onPressed2: () {
                      Navigator.pushNamed(context, 'SignIn');
                    },
                  );
          },
        ),
      ),
    );
  }

  Future<BaseModel<Doctordetails>> _doctordetail() async {
    Doctordetails response;
    setState(() {
      _loadding = true;
    });
    try {
      response = await RestClient(Retro_Api2().Dio_Data2()).doctoedetailRequest(id);
      if (response.success == true) {
        setState(
          () {
            _loadding = false;
            id = response.data!.id;
            name = response.data!.name;
            rate = response.data!.rate.toDouble();
            experience = response.data!.experience;
            appointmentFees = response.data!.appointmentFees;
            desc = response.data!.desc;
            expertise = response.data!.expertise!.name;
            fullImage = response.data!.fullImage;
            treatmentname = response.data!.treatment!.name;
            reviews.addAll(response.data!.reviews!);

            hosiptaldetail.addAll(response.data!.hosiptal!);
            for (int i = 0; i < hosiptaldetail.length; i++) {
              mobileNo = hosiptaldetail[i].phone;
            }
            var convert_degree = json.decode(response.data!.education!);
            degree.clear();
            collage.clear();
            de_year.clear();
            for (int i = 0; i < convert_degree.length; i++) {
              degree.add(convert_degree[i]['degree']);
              collage.add(convert_degree[i]['college']);
              de_year.add(convert_degree[i]['year']);
            }
            var convert_certificate = json.decode(response.data!.certificate!);
            award.clear();
            ce_year.clear();
            for (int i = 0; i < convert_certificate.length; i++) {
              award.add(convert_certificate[i]['certificate']);
              ce_year.add(convert_certificate[i]['certificate_year']);
            }
          },
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
