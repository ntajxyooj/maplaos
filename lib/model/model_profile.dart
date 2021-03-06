import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:rich_alert/rich_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelProfile extends StatefulWidget {
  @override
  _ModelProfileState createState() => _ModelProfileState();
}

class _ModelProfileState extends State<ModelProfile> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Setting setting = Setting();
  bool isloading = false;
  bool isloadinit = true;
  var first_name;
  var last_name;
  var email;
  var phone;
  var username;
  var password;
  var profile_id;
  var user_id;
  void loadprofile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var profiles = await conn.query('select * from user left join profile on profile.id=user.profile_id where user.id=?', [userId]);
    for(var profile in profiles){
      setState(() {
        isloadinit=false;
        first_name=profile['first_name'];
        last_name=profile['last_name'];
        email=profile['email'];
        phone=profile['phone'];
        username=profile['username'];
        password=profile['password'];
        profile_id=profile['profile_id'];
        user_id=userId;
      });
    }
    await conn.close();
  }

  void editprofile() async {
    setState(() {
      isloading = true;
    });
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var data = _fbKey.currentState.value;
    var saveprofile = await conn.query(
        'update profile set first_name=?, last_name=?, email=?, phone=? where id=?',
        [data['first_name'], data['last_name'], data['email'], data['phone'],profile_id]);

      var newpassword;
      if(data['password'].toString()==password.toString()){
        newpassword=password;
      }else{
        newpassword=md5.convert(utf8.encode(data['password'])).toString();
      }
      var saveuser = await conn.query(
          'update user set username=?, password=?, status=?, type=?, profile_id=? where id=?',
          [
            data['username'],
            newpassword,
            1,
            'user',
            profile_id,
            user_id
          ]);

        setState(() {
          isloading = false;
        });
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RichAlertDialog(
                //uses the custom alert dialog
                alertTitle: richTitle(('Successed').tr()),
                alertSubtitle:
                    richSubtitle(("Click button below").tr()),
                alertType: RichAlertType.SUCCESS,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.border_all,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
    await conn.close();
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadprofile();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(('Profile').tr(),
          textAlign: TextAlign.center,
        )),
      ),
      body: isloadinit?Center(child: CircularProgressIndicator(),): ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FormBuilder(
              key: _fbKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "first_name",
                    initialValue:'$first_name',
                    decoration: InputDecoration(labelText:('First name').tr()),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:('Please enter first name').tr()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "last_name",
                    initialValue:'$last_name',
                    decoration:
                        InputDecoration(labelText: ('Last name').tr()),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:('Please enter last name').tr()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "email",
                    initialValue:'$email',
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText:('Email').tr()),
                    validators: [
                      FormBuilderValidators.max(255),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "phone",
                    initialValue:'$phone',
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText:('Phone number').tr()),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:('Please enter phone number').tr()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  Divider(),
                  FormBuilderTextField(
                    attribute: "username",
                    initialValue:'$username',
                    decoration:
                        InputDecoration(labelText:("Username").tr()),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:("Please enter username").tr()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password",
                    initialValue:'$password',
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText:("Password").tr()),
                    validators: [
                      FormBuilderValidators.required(
                          errorText:('Please enter password').tr()),
                      FormBuilderValidators.min(4,
                          errorText:('Password must contain 4 or more digits').tr()),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  FormBuilderTextField(
                    attribute: "password_confirm",
                    initialValue:'$password',
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText:("Password confirm").tr()),
                    validators: [
                      FormBuilderValidators.required(),
                      (val) {
                        if (_fbKey.currentState.fields['password'].currentState
                                .value !=
                            val) {
                          return ("Password confirm is incorect").tr();
                        }
                      }
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: isloading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : RaisedButton.icon(
                                icon: Icon(
                                  Icons.save,
                                  color: Colors.white,
                                ),
                                label: Text(("Submit").tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                key: null,
                                onPressed: () {
                                  if (_fbKey.currentState.saveAndValidate()) {
                                    editprofile();
                                  }
                                },
                                color: Colors.red,
                              ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
