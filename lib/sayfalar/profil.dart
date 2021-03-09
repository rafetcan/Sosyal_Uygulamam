import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profiliduzenle.dart';
import 'package:socialapp/sayfalar/tekligonderi.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';
import 'package:socialapp/widgetlar/gonderikarti.dart';

class Profil extends StatefulWidget {
  final String profilSahibiId;

  const Profil({Key key, this.profilSahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _gonderiSayisi = 0;
  int _takipci = 0;
  int _takipEdilen = 0;
  List<Gonderi> _gonderiler = [];
  String gonderiStili = "liste";
  String _aktifKullaniciId;
  Kullanici _profilSahibi;
  bool _takipEdildi = false;

  _takipciSayisiGetir() async {
    int takipciSayisi = await FireStoreServisi().takipciSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipci = takipciSayisi;
      });
    }
  }

  _takipEdilenSayisiGetir() async {
    int takipEdilenSayisi = await FireStoreServisi().takipEdilenSayisi(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _takipEdilen = takipEdilenSayisi;
      });
    }
  }

  _gonderileriGetir() async {
    List<Gonderi> gonderiler = await FireStoreServisi().gonderileriGetir(widget.profilSahibiId);
    if (mounted) {
      setState(() {
        _gonderiler = gonderiler;
        _gonderiSayisi = gonderiler.length;
      });
    }
  }

  _takipKontrol() async {
    bool takipVarMi = await FireStoreServisi()
        .takipKontrol(profilSahibiId: widget.profilSahibiId, aktifKullaniciId: _aktifKullaniciId);

    setState(() {
      _takipEdildi = takipVarMi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipciSayisiGetir();
    _takipEdilenSayisiGetir();
    _gonderileriGetir();
    _aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
    _takipKontrol();
  }

  @override
  Widget build(BuildContext context) {
    // setTest() {
    //   setState(() {
    //     LinearProgressIndicator();
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.grey[100],
        actions: [
          widget.profilSahibiId == _aktifKullaniciId
              ? IconButton(icon: Icon(Icons.exit_to_app, color: Colors.black), onPressed: _cikisYap)
              : IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text("Seçiminiz Nedir?"),
                          children: [
                            SimpleDialogOption(
                              child: Text("Profili şikayet et..."),
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text('Henüz çalışmalarımız bitmedi.'),
                                  duration: const Duration(seconds: 2),
                                ));
                              },
                            ),
                            SimpleDialogOption(
                              child: Text("Vazgeç", style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        );
                      },
                    );
                  }),
        ],
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<Object>(
        future: FireStoreServisi().kullaniciGetir(widget.profilSahibiId),
        builder: (context, snapshot) {
          //
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          _profilSahibi = snapshot.data;

          return ListView(
            children: [
              _profilDetaylari(snapshot.data),
              _gonderileriGoster(snapshot.data),
            ],
          );
        },
      ),
    );
  }

  Widget _gonderileriGoster(Kullanici profilData) {
    if (gonderiStili == "liste1") {
      return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: _gonderiler.length,
        itemBuilder: (context, index) {
          return GonderiKarti(
            gonderi: _gonderiler[index],
            yayinlayan: profilData,
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      _gonderiler.forEach((gonderi) {
        fayanslar.add(_fayansOlustur(gonderi));
      });
      return GridView.count(
        shrinkWrap: true, // sadece ihtiyacın kadar alanı kapla
        crossAxisCount: 3,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        children: fayanslar,
      );
    }
  }

  GridTile _fayansOlustur(Gonderi gonderi) {
    return GridTile(
        child: GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TekliGonderi(
                    gonderiId: gonderi.id,
                    gonderiSahibiId: gonderi.yayinlayanId,
                  ))),
      child: Image.network(
        gonderi.gonderiResmiUrl,
        fit: BoxFit.cover,
      ),
    ));
  }

  Widget _profilDetaylari(Kullanici profileData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 50,
                  backgroundImage: NetworkImage(profileData.fotoUrl.isNotEmpty
                      ? profileData.fotoUrl
                      : "https://rafethokka.com/app/socialapp/avatar/001.png")),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosyalSayac(baslik: "Gönderiler", sayi: _gonderiSayisi),
                    _sosyalSayac(baslik: "Takipçi", sayi: _takipci),
                    _sosyalSayac(baslik: "Takip", sayi: _takipEdilen),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            profileData.kullaniciAdi,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(profileData.hakkinda),
          SizedBox(height: 25),
          widget.profilSahibiId == _aktifKullaniciId
              ? _profileDuzenleButton()
              : _takipveMesajButonu(),
        ],
      ),
    );
  }

  Widget _takipveMesajButonu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _takipEdildi ? _takiptenCikButonu() : _takipEtButonu(),
        Container(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Henüz çalışmalarımız bitmedi.'),
                duration: const Duration(seconds: 2),
                // action: SnackBarAction(
                //   label: 'Tamam',
                //   onPressed: () {},
                // ),
              ));
            },
            child: Text(
              'Mesaj Gönder',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _takipEtButonu() {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: ElevatedButton(
        // color: Theme.of(context).primaryColor,
        onPressed: () {
          FireStoreServisi()
              .takipEt(profilSahibiId: widget.profilSahibiId, aktifKullaniciId: _aktifKullaniciId);

          setState(() {
            _takipEdildi = true;
            _takipci = _takipci + 1;
          });
        },
        child: Text(
          'Takip Et',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _takiptenCikButonu() {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: OutlinedButton(
        onPressed: () {
          FireStoreServisi().takiptenCik(
              profilSahibiId: widget.profilSahibiId, aktifKullaniciId: _aktifKullaniciId);

          setState(() {
            _takipEdildi = false;
            _takipci = _takipci - 1;
          });
        },
        child: Text(
          'Takipten Çık',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _profileDuzenleButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfiliDuzenle(profil: _profilSahibi)))
              .then((value) => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Profil(
                            profilSahibiId: _aktifKullaniciId,
                          ))));
        },
        child: Text('Profili Düzenle'),
      ),
    );
  }

  Widget _sosyalSayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  void _cikisYap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
