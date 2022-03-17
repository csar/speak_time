import 'dart:html' as webFile;

class Writer {
  String name;
  Writer(this.name);

  save(String data) {
    var blob = webFile.Blob([data], 'text/csv', 'native');

    var anchorElement = webFile.AnchorElement(
      href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
    )..setAttribute("download", name)..click();
  }
}