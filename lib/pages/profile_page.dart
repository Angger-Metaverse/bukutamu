import 'package:flutter/material.dart';

import 'public_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'About',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/me.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nanda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.grey[300],
              thickness: 2,
              height: 30,
            ),
            ListTile(
              leading: Icon(
                Icons.flip_camera_android,
                color: Colors.blue,
              ),
              title: Text(
                'nanda.wahyuni',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.email,
                color: Colors.blue,
              ),
              title: Text(
                'nandawhy@gmail.com',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.green,
              ),
              title: Text(
                '089654742445',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              height: 20,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red, // Text color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PublicPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Logout'),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'nandawhy 2024',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
