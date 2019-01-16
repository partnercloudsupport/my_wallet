class AboutEntity {
  final String version;
  final String text;
  final String emphasize;
  List<AboutTextInfo> _list = [];

  AboutEntity(this.version, this.text, {this.emphasize = ""});

  List<AboutTextInfo> get aboutUs {
    if(text == null || text.isEmpty) return [];
    if(_list != null && _list.isNotEmpty) return _list;

    if(emphasize.isNotEmpty) {
      List<String> splits = text.split(emphasize);

      for (String s in splits) {
        _list.add(AboutTextInfo(TextType.normal, s));
        _list.add(AboutTextInfo(TextType.emphasized, emphasize));
      }

      if (!text.endsWith(emphasize)) _list.removeLast();
    }

    return _list;
  }
}

class AboutTextInfo {
  final TextType type;
  final String text;

  AboutTextInfo(this.type, this.text);
}

enum TextType {
  emphasized,
  normal,
}