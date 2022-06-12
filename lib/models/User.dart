class UserModel {
  String? uid;
  String? email;

  UserModel({this.uid, this.email});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    email = map["email"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
    };
  }
}
