import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/modeller/mesaj.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class Mesajlar extends StatefulWidget {
  @override
  _MesajlarState createState() => _MesajlarState();
}

class _MesajlarState extends State<Mesajlar> {
  int _gonderilenMesajSayisi = 0;
  String _aktifKullaniciId;
  List<Mesaj> _mesajlar = [];
  Mesaj _mesaj;

  @override
  void initState() {
    super.initState();
    mesajSayilariniGetir();
  }

  mesajSayilariniGetir() async {
    _aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

    _gonderilenMesajSayisi = await FireStoreServisi().gonderilenMesajSayisi(_aktifKullaniciId);
    print(_aktifKullaniciId + " " + _gonderilenMesajSayisi.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Mesajlar", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
      ),
      body: FutureBuilder<List<Mesaj>>(
        future: FireStoreServisi().gonderilenMesajlar(_aktifKullaniciId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }

          _mesajlar = snapshot.data;

          return ListView.builder(
            itemCount: _mesajlar.length,
            itemBuilder: (context, index) {
              return mesajlariListele(_mesajlar[index]);
            },
          );
        },
      ),
    );
  }

  Widget mesajlariListele(Mesaj mesaj) {
    return FutureBuilder<Kullanici>(
      future: FireStoreServisi().kullaniciGetir(mesaj.mesajiAlanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        //
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(snapshot.data.fotoUrl.isNotEmpty
                ? snapshot.data.fotoUrl
                : "https://rafethokka.com/app/socialapp/avatar/016.png"),
          ),
          title: RichText(
            text: TextSpan(
              text: snapshot.data.kullaniciAdi,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              children: <TextSpan>[
                TextSpan(text: ' ${mesaj.mesaj}', style: TextStyle(fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          // title: Text(snapshot.data.kullaniciAdi + " : " + mesaj.mesaj),
          trailing: Icon(Icons.arrow_forward_ios),
        );
      },
    );
  }
}
