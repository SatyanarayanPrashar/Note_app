class NoteModel {
  String? noteid;
  String? title;
  String? note;
  String? image;
  DateTime? createdon;

  NoteModel({this.noteid, this.title, this.note, this.image, this.createdon});

  NoteModel.fromMap(Map<String, dynamic> map) {
    noteid = map["noteid"];
    title = map["title"];
    note = map["note"];
    image = map["image"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "noteid": noteid,
      "title": title,
      "note": note,
      "image": image,
      "createdon": createdon,
    };
  }
}
