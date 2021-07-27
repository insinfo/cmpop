class PaginaItem {
  String id;
  String key;
  String title;
  String content;

  PaginaItem({this.id});

  PaginaItem.fromMap(Map<String, dynamic> map) {
    try {
      id = map['id'];
      key = map['key'];
      title = map['title'];
      content = map['content'];
    } catch (e) {
      print('PaginaItem.fromMap: $e');
    }
  }

  Map<String, dynamic> toMap() {
    var result = <String, dynamic>{
      'id': id,
      'key': key,
      'title': title,
      'content': content,
    };

    return result;
  }
}
