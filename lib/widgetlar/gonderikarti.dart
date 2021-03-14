import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/gonderi.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/sayfalar/yorumlar.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi gonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.gonderi, this.yayinlayan}) : super(key: key);

  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int _begeniSayisi = 0;
  bool _begendin = false;
  String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.gonderi.begeniSayisi;
    _aktifKullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi = await FireStoreServisi().begeniVarmi(widget.gonderi, _aktifKullaniciId);

    if (begeniVarmi) {
      if (mounted) {
        setState(() {
          _begendin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          _gonderiBasligi(),
          _gonderiResmi(),
          _gonderiAlt(),
        ],
      ),
    );
  }

  gonderiSecenekleri() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Seçiminiz Nedir?"),
          children: [
            SimpleDialogOption(
              child: Text("Gönderiyi Düzenle"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Henüz çalışmalarımız bitmedi.'),
                  duration: const Duration(seconds: 2),
                  // action: SnackBarAction(
                  //   label: 'Tamam',
                  //   onPressed: () {},
                  // ),
                ));
              },
            ),
            SimpleDialogOption(
              child: Text("Yorum yapmayı kapat"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Henüz çalışmalarımız bitmedi.'),
                  duration: const Duration(seconds: 2),
                  // action: SnackBarAction(
                  //   label: 'Tamam',
                  //   onPressed: () {},
                  // ),
                ));
              },
            ),
            SimpleDialogOption(
              child: Text("Gönderiyi Sil"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                FireStoreServisi()
                    .gonderiSil(aktifKullaniciId: _aktifKullaniciId, gonderi: widget.gonderi);
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
  }

  sikayetGonderiSecenekleri() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Seçiminiz Nedir?"),
          children: [
            SimpleDialogOption(
              child: Text("Şikayet et..."),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Henüz çalışmalarımız bitmedi.'),
                  duration: const Duration(seconds: 2),
                  // action: SnackBarAction(
                  //   label: 'Tamam',
                  //   onPressed: () {},
                  // ),
                ));
              },
            ),
            SimpleDialogOption(
              child: Text("Takibi Bırak"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Henüz çalışmalarımız bitmedi.'),
                  duration: const Duration(seconds: 2),
                  // action: SnackBarAction(
                  //   label: 'Tamam',
                  //   onPressed: () {},
                  // ),
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
  }

  Widget _gonderiBasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
          },
          child: CircleAvatar(
              backgroundColor: Colors.grey[100],
              backgroundImage: NetworkImage(widget.yayinlayan.fotoUrl.isNotEmpty
                  ? widget.yayinlayan.fotoUrl
                  : "https://rafethokka.com/app/socialapp/avatar/001.png")),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Profil(profilSahibiId: widget.gonderi.yayinlayanId)));
        },
        child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: _aktifKullaniciId == widget.gonderi.yayinlayanId
          ? IconButton(icon: Icon(Icons.more_vert), onPressed: () => gonderiSecenekleri())
          : IconButton(icon: Icon(Icons.more_vert), onPressed: () => sikayetGonderiSecenekleri()),
      contentPadding: EdgeInsets.all(0.0),
    );
  }

  Widget _gonderiResmi() {
    return GestureDetector(
      onDoubleTap: _begeniDegistir,
      child: Image.network(
        widget.gonderi.gonderiResmiUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderiAlt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: !_begendin
                  ? Icon(Icons.favorite_border, size: 35.0)
                  : Icon(Icons.favorite, color: Colors.red, size: 35.0),
              onPressed: _begeniDegistir,
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.comment, size: 30.0),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Yorumlar(
                              gonderi: widget.gonderi,
                            )));
              },
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "$_begeniSayisi beğeni",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 2.0),
        widget.gonderi.aciklama.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                  text: TextSpan(
                      text: widget.yayinlayan.kullaniciAdi + " ",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                            text: widget.gonderi.aciklama,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.0))
                      ]),
                ),
              )
            : SizedBox(height: 0.0),
      ],
    );
  }

  void _begeniDegistir() {
    if (_begendin) {
      // Kullanıcı gönderiyi beğenmiş durumda, öyleyse beğeniyi kaldıracak kodları çalışralım
      setState(() {
        _begendin = false;
        _begeniSayisi = _begeniSayisi - 1;
      });
      FireStoreServisi().gonderiBegeniKaldir(widget.gonderi, _aktifKullaniciId);
    } else {
      // kullanıcı gönderi beğenmemiş, beğeni ekleyen kodları çalıştıralım.
      setState(() {
        _begendin = true;
        _begeniSayisi = _begeniSayisi + 1;
      });
      FireStoreServisi().gonderiBegen(widget.gonderi, _aktifKullaniciId);
    }
  }
}
