class Info {
  String id;
  String title;
  String lang;
  String content;
  String content2;
  String linkLabel;

  Info({this.id, this.title, this.lang, this.content, this.content2});

  Info.fromMap(Map<String, dynamic> map) {
    id = map['id'];

    if (map.containsKey('title')) {
      title = map['title'];
    }
    if (map.containsKey('lang')) {
      lang = map['lang'];
    }
    if (map.containsKey('content')) {
      content = map['content'];
    }
    if (map.containsKey('content2')) {
      content2 = map['content2'];
    }
    if (map.containsKey('linkLabel')) {
      linkLabel = map['linkLabel'];
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (id != null) {
      map['id'] = id;
    }
    if (title != null) {
      map['title'] = title;
    }

    map['lang'] = lang;

    if (content != null) {
      map['content'] = content;
    }
    if (content2 != null) {
      map['content2'] = content2;
    }

    if (linkLabel != null) {
      map['linkLabel'] = linkLabel;
    }

    return map;
  }
}
