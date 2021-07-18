import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/comments.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CommetPage extends StatefulWidget {
  String id;
  String animalOwnerMobileNo;
  CommetPage({Key? key, required this.id, required this.animalOwnerMobileNo})
      : super(key: key);

  @override
  _CommetPageState createState() => _CommetPageState(id, animalOwnerMobileNo);
}

class _CommetPageState extends State<CommetPage> {
  TextEditingController _commentController = TextEditingController();
  Map<String, String> _currentUserInfoMap = {};

  int _count = 0;
  String id;
  String animalOwnerMobileNo;
  _CommetPageState(this.id, this.animalOwnerMobileNo);

  Future<void> _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
    });
    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserInfoMap = userProvider.currentUserMap;
        print(
            'The profile image in comment section = ${_currentUserInfoMap['profileImageLink']!}');
      });
    });
  }

  @override
  void initState() {
    print('The post id is $id');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    if (_count == 0) _customInit(userProvider);
    Size size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();
    double appbar_height = appBar.preferredSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Animals')
                    .doc(id)
                    .collection('comments')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  return new ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return CommentsDemo(comment: data['comment']);
                    }).toList(),
                  );
                }),
            Positioned(
              bottom: 0.0,
              child: Container(
                  width: size.width,
                  height: appbar_height,
                  color: Colors.white,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    elevation: size.width * .04,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * .8,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * .03, 0.0, 0.0, 0.0),
                                child: CircleAvatar(
                                  backgroundImage: (_currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              null ||
                                          _currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              '')
                                      ? AssetImage(
                                          'assets/profile_image_demo.png')
                                      : NetworkImage(_currentUserInfoMap[
                                              'profileImageLink']!)
                                          as ImageProvider,
                                  radius: size.width * .04,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(size.width * .03,
                                    0.0, size.width * .03, 0.0),
                                width: size.width * .6,
                                child: _commentField(context),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_commentController.text.isEmpty) {
                              return;
                            }
                            final _commentId = Uuid().v4();
                            String date = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            animalProvider
                                .addComment(
                                    id,
                                    _commentId,
                                    _commentController.text,
                                    animalOwnerMobileNo,
                                    _currentUserInfoMap['mobileNo']!,
                                    date,
                                    '')
                                .then((value) {
                              _commentController.clear();
                            });
                          },
                          child: Text(
                            'Post',
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * .038),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Add a comment',
        hintStyle: TextStyle(
          fontSize: size.width * .04,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      cursorColor: Colors.black,
    );
  }
}
