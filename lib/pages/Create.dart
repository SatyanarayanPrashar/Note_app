import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo/models/NoteModel.dart';
import 'package:todo/pages/Home_Page.dart';
import '../main.dart';
import '../models/UIHelper.dart';
import '../models/User.dart';

class Create_note extends StatefulWidget {
  final UserModel currentUser;
  final User firebaseUser;

  const Create_note(
      {super.key, required this.currentUser, required this.firebaseUser});

  @override
  State<Create_note> createState() => _Create_noteState();
}

class _Create_noteState extends State<Create_note> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                )
              ],
            ),
          );
        });
  }

  void checkValues() {
    String note = noteController.text.trim();
    String? title = titleController.text.trim();

    if (imageFile == null) {
      const snackBar = SnackBar(
        content: Text("Please choose a picture!"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // Create Post
      createNote();
    }
  }

  void createNote() async {
    UIHelper.showLoadingAlertDialog(context, "Uploading..");

    String imgName =
        widget.currentUser.email! + DateTime.now().toString() + uuid.v1();

    UploadTask uploadTask =
        FirebaseStorage.instance.ref(imgName).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();

    String? note = noteController.text.trim();
    String title = titleController.text.trim();

    NoteModel newNote = NoteModel(
      noteid: uuid.v1(),
      title: title,
      note: note,
      image: imageUrl,
      createdon: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUser.uid)
        .collection("notes")
        .doc(newNote.noteid)
        .set(newNote.toMap());

    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUser.uid)
        .set(widget.currentUser.toMap())
        .then((value) {
      log("new Note Created");
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Home_Page(
          currentUser: widget.currentUser,
          firebaseUser: widget.firebaseUser,
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          checkValues();
        },
        label: const Text("Add"),
        icon: const Icon(Icons.add),
      ),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 21,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    label: Text(
                      "Tittle",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              //
              const SizedBox(height: 10),
              //
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  maxLines: null,
                  controller: noteController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    label: Text(
                      "Note",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
              ),
//
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      // borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: (imageFile == null)
                        ? const Icon(
                            Icons.image,
                            size: 60,
                          )
                        : Image(
                            image: FileImage(imageFile!),
                          ),
                  ),
                  IconButton(
                    onPressed: () {
                      showPhotoOptions();
                    },
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              //
              SizedBox(height: size.height * 0.55),
            ],
          ),
        ),
      ),
    );
  }
}
