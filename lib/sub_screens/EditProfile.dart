import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_lover/custom_classes/DatabaseManager.dart';
import 'package:pet_lover/custom_classes/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileUser extends StatefulWidget {
  @override
  _EditProfileUserState createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<EditProfileUser> {
  final picker = ImagePicker();
  File? _image;
  File? _croppedImage;
  String? profileImageLink;
  bool profileImageUploadVisibility = false;
  String? _currentMobileNo;
  late Stream documentStream;
  String? _username,
      _mobileNo,
      _address,
      _about,
      _profileImageLink,
      _registrationDate;
  String? username, mobileNo, address, about, imageLink, registrationDate;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _mobileNoController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    _currentMobileNo = await getCurrentMobileNo();
    _username =
        await DatabaseManager().getUserInfo(_currentMobileNo!, 'username');
    _mobileNo =
        await DatabaseManager().getUserInfo(_currentMobileNo!, 'mobileNo');
    _address =
        await DatabaseManager().getUserInfo(_currentMobileNo!, 'address');
    _about = await DatabaseManager().getUserInfo(_currentMobileNo!, 'about');
    _profileImageLink = await DatabaseManager()
        .getUserInfo(_currentMobileNo!, 'profileImageLink');
    _registrationDate = await DatabaseManager()
        .getUserInfo(_currentMobileNo!, 'registrationDate');

    setState(() {
      username = _username;
      _usernameController.text = username!;
      mobileNo = _mobileNo;
      _mobileNoController.text = mobileNo!;
      address = _address;
      _addressController.text = address!;
      about = _about;
      _aboutController.text = about!;
      imageLink = _profileImageLink;
      print('profile image link - $imageLink');
      registrationDate = _registrationDate;
    });

    print('$_username $_mobileNo $_address');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _mobileNoController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView(children: [
      Container(
        width: size.width,
        height: size.width * .8,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: size.width * .5,
                  width: size.width * .5,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepOrange,
                    child: CircleAvatar(
                      radius: size.width * .245,
                      backgroundColor: Colors.white,
                      backgroundImage: imageLink == ''
                          ? _image == null
                              ? AssetImage('assets/profile_image_demo.png')
                              : FileImage(_image!) as ImageProvider
                          : _image == null
                              ? NetworkImage(imageLink.toString())
                              : FileImage(_image!) as ImageProvider,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1,
                              color:
                                  Theme.of(context).scaffoldBackgroundColor)),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _cameraGalleryBottomSheet(context);
                        },
                      )),
                )
              ],
            ),
            SizedBox(
              height: size.width * .04,
            ),
            Visibility(
              visible: profileImageUploadVisibility,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileImageUploadVisibility = false;
                        });
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey)),
                      child: Text('CANCEL')),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _uploadImage(_image!).then((value) async {
                            String? _currentMobileNo =
                                await getCurrentMobileNo();
                            print('currentMobile - $_currentMobileNo');
                            profileImageLink = await DatabaseManager()
                                .profileImageDownloadUrl(_currentMobileNo!);
                            imageLink = profileImageLink;

                            print('profile image link - $profileImageLink');
                            await DatabaseManager().updatingProfileImageLink(
                                profileImageLink!, _currentMobileNo);
                            Navigator.pop(context);
                          });
                          profileImageUploadVisibility = false;
                        });
                      },
                      child: Text('UPLOAD')),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: size.width * .1),
      Container(
        width: size.width,
        padding: EdgeInsets.only(
          left: size.width * .04,
          right: size.width * .04,
        ),
        child: Column(
          children: [
            Container(
              width: size.width,
              child: Text(
                'Basic Information',
              ),
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Divider(
              height: size.width * .02,
              thickness: size.width * .01,
              color: Colors.black,
            ),
            SizedBox(
              height: size.width * .04,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Text(
                  'Username',
                  style: TextStyle(fontSize: size.width * .042),
                )
              ],
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: size.width * .04,
                  right: size.width * .04,
                  top: size.width * .02,
                  bottom: size.width * .02),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey)),
              child: textFormFieldBuilder(
                  TextInputType.text, 1, _usernameController),
            ),
            SizedBox(height: size.width * .04),
            Row(
              children: [
                Icon(
                  Icons.phone_android_outlined,
                  color: Colors.black,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Text(
                  'Mobile number',
                  style: TextStyle(fontSize: size.width * .042),
                )
              ],
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: size.width * .04,
                  right: size.width * .04,
                  top: size.width * .02,
                  bottom: size.width * .02),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey)),
              child: textFormFieldBuilder(
                  TextInputType.text, 1, _mobileNoController),
            ),
            SizedBox(height: size.width * .04),
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: Colors.black,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Text(
                  'Address',
                  style: TextStyle(fontSize: size.width * .042),
                )
              ],
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: size.width * .04,
                  right: size.width * .04,
                  top: size.width * .02,
                  bottom: size.width * .02),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey)),
              child: textFormFieldBuilder(
                  TextInputType.text, 1, _addressController),
            ),
            SizedBox(height: size.width * .04),
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.black,
                ),
                SizedBox(
                  width: size.width * .02,
                ),
                Text(
                  'About',
                  style: TextStyle(fontSize: size.width * .042),
                )
              ],
            ),
            SizedBox(
              height: size.width * .02,
            ),
            Container(
              width: size.width,
              padding: EdgeInsets.only(
                  left: size.width * .04,
                  right: size.width * .04,
                  top: size.width * .02,
                  bottom: size.width * .02),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey)),
              child:
                  textFormFieldBuilder(TextInputType.text, 6, _aboutController),
            ),
            SizedBox(height: size.width * .04),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                    child: Text('CANCEL')),
                SizedBox(width: size.width * .04),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _updateUserData().then((value) {
                          print('update successful');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      });
                    },
                    child: Text('UPDATE')),
              ],
            ),
            SizedBox(height: size.width * .06),
          ],
        ),
      )
    ]);
  }

  Future _updateUserData() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ProgressDialog(message: 'Please wait... updating data');
        });
    await DatabaseManager().updateUserInfo(
        _usernameController.text,
        _mobileNoController.text,
        _addressController.text,
        registrationDate!,
        imageLink!,
        _aboutController.text);
  }

  Future _getGalleryImage() async {
    final _originalImage =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (_originalImage != null) {
      _croppedImage = await ImageCropper.cropImage(
          sourcePath: _originalImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          androidUiSettings: AndroidUiSettings(
            lockAspectRatio: false,
          )).then((value) {
        setState(() {
          _image = value;
        });
      });
    }
  }

  Future _getCameraImage() async {
    final _originalImage =
        await ImagePicker().getImage(source: ImageSource.camera);

    if (_originalImage != null) {
      _croppedImage = await ImageCropper.cropImage(
          sourcePath: _originalImage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          androidUiSettings: AndroidUiSettings(
            lockAspectRatio: false,
          )).then((value) {
        setState(() {
          _image = value;
        });
      });
    }
  }

  Widget textFormFieldBuilder(TextInputType keyboardType, int maxLine,
      TextEditingController textEditingController) {
    return Column(
      children: [
        TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            keyboardType: keyboardType,
            cursorColor: Colors.black,
            maxLines: maxLine),
      ],
    );
  }

  void _cameraGalleryBottomSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: size.width * .3,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * .03),
                      topRight: Radius.circular(size.width * .03))),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(FontAwesomeIcons.camera),
                    title: Text('Camera'),
                    onTap: () {
                      setState(() {
                        _getCameraImage();
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.images),
                    title: Text('Gallery'),
                    onTap: () {
                      setState(() {
                        _getGalleryImage();
                        Navigator.pop(context);
                      });
                    },
                  )
                ],
              ),
            ),
          );
        }).then((value) {
      profileImageUploadVisibility = true;
    });
  }

  Future<String?> getCurrentMobileNo() async {
    final prefs = await SharedPreferences.getInstance();
    _currentMobileNo = prefs.getString('mobileNo');
    print('Current Mobile no is $_currentMobileNo');
    return _currentMobileNo;
  }

  Future _uploadImage(File _imageFile) async {
    String? _currentMobileNo = await getCurrentMobileNo();
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ProgressDialog(
                message: 'Please wait... while your image is being uploaded');
          });
      await DatabaseManager().uploadProfileImage(_currentMobileNo!, _imageFile);
    } catch (error) {
      print('profile image uplaod failed, error - $error');
    }
  }
}
