import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController _aramaController = TextEditingController();
  Future<List<Kullanici>> _aramaSonucu;
  List<Kullanici> _kullanicilar = [];

  _kullanicilariGetir() async {
    List<Kullanici> kullanicilar = await FireStoreServisi().kesfetKullanicilariGetir();
    if (mounted) {
      setState(() {
        _kullanicilar = kullanicilar;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _kullanicilariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarOlustur(),
      body: _aramaSonucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar _appBarOlustur() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        onFieldSubmitted: (girilenDeger) {
          setState(() {
            _aramaSonucu = FireStoreServisi().kullaniciAra(girilenDeger);
          });
        },
        controller: _aramaController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, size: 30.0),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _aramaController.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              }),
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: "Kullanıcı Ara...",
          contentPadding: EdgeInsets.only(top: 16.0), //yukarıdan boşluk
        ),
      ),
    );
  }

  String kullaniciStili = "liste1";
  Widget aramaYok() {
    if (kullaniciStili == "liste") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _kullanicilar.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_kullanicilar[index].kullaniciAdi),
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      _kullanicilar.forEach((kullanici) {
        fayanslar.add(_fayansOlustur(kullanici));
      });
      return GridView.count(
        shrinkWrap: true, // sadece ihtiyacın kadar alanı kapla
        crossAxisCount: 3,
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Kullanici kullanici) {
    return GridTile(
        child: GestureDetector(
      onTap: () => Get.to(Profil(profilSahibiId: kullanici.id)),
      /*//! Temizlenecek
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => Profil(profilSahibiId: kullanici.id))),*/
      child: Image.network(
        kullanici.fotoUrl.isNotEmpty
            ? kullanici.fotoUrl
            : "https://rafethokka.com/app/socialapp/avatar/016.png",
        fit: BoxFit.cover,
      ),
    ));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
      future: _aramaSonucu,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.length == 0) {
          return Center(child: Text("Bu arama için sonuç bulunamadı"));
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Kullanici kullanici = snapshot.data[index];
            return kullaniciSatiri(kullanici);
          },
        );
      },
    );
  }

  kullaniciSatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () => Get.to(Profil(profilSahibiId: kullanici.id)),
      /* //!Temizlenecek
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Profil(profilSahibiId: kullanici.id))), */
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
          backgroundColor: Colors.grey[100],
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
