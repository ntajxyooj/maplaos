import 'package:flutter/material.dart';
class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ກ່ຽວ​ກັບ​ພວກ​ເຮົາ​/About Us'),
      ),
      body: Container(
        child:Center(
          child: Text('Comming soon'),
        ),
      ),
    );
  }
}