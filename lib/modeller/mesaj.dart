import 'package:cloud_firestore/cloud_firestore.dart';

class Mesaj {
  final String id;
  final String mesaj;
  final String mesajResimUrl;
  final String mesajiAlanId;
  final String mesajiGonderenId;
  final Timestamp olusturulmaZamani;

  Mesaj(
      {this.id,
      this.mesaj,
      this.mesajResimUrl,
      this.mesajiAlanId,
      this.mesajiGonderenId,
      this.olusturulmaZamani});

  factory Mesaj.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Mesaj(
      id: doc.id,
      mesaj: docData["mesaj"],
      mesajResimUrl: docData["mesajResimUrl"],
      mesajiAlanId: docData["mesajiAlanId"],
      mesajiGonderenId: docData["mesajiGonderenId"],
      olusturulmaZamani: docData["olusturulmaZamani"],
    );
  }
}
