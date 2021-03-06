import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/yukle.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';
import 'package:socialapp/widgetlar/silinmeyenFutureBuilder.dart';

class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  List<Gonderi> _gonderiler = [];

  _akisGonderileriniGetir() async {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
    List<Gonderi> gonderiler = await FireStoreServisi().akisGonderileriGetir(aktifKullaniciId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _akisGonderileriniGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Yukle()));
          },
          iconSize: 18.0,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text("Social App", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.inbox),
            onPressed: () {},
            iconSize: 20.0,
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          Gonderi gonderi = _gonderiler[index];

          return SilinmeyenFutureBuilder(
            future: FireStoreServisi().kullaniciGetir(gonderi.yayinlayanId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              }

              Kullanici gonderiSahibi = snapshot.data;
              return GonderiKarti(gonderi: gonderi, yayinlayan: gonderiSahibi);
            },
          );
        },
      ),
    );
  }
}
