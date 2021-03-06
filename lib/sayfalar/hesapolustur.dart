import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/modeller/kullanici.dart';
import 'package:socialapp/servisler/firestoreservisi.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class HesapOlustur extends StatefulWidget {
  @override
  _HesapOlusturState createState() => _HesapOlusturState();
}

class _HesapOlusturState extends State<HesapOlustur> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();

  bool yukleniyor = false;
  String kullaniciAdi, email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(title: Text("Hesap Oluştur")),
        body: ListView(
          children: [
            yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formAnahtari,
                child: Column(
                  children: [
                    TextFormField(
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: "Kullanıcı Adınızı Girin",
                        labelText: "Kullanıcı Adı:",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger.isEmpty) {
                          return "Kullanıcı Adı Alanı boş bırakılamaz!";
                        } else if (girilenDeger.trim().length < 4 ||
                            girilenDeger.trim().length > 10) {
                          return "En az 4 en fazla 10 karakter olabilir!";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => kullaniciAdi = girilenDeger,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email Adresinizi Girin",
                        labelText: "Email:",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger.isEmpty) {
                          return "Email Alanı boş bırakılamaz!";
                        } else if (!girilenDeger.contains("@")) {
                          return "Girilen Değer ail formatında olmalı!";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => email = girilenDeger,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Şifrenizi Girin",
                        labelText: "Şifre:",
                        errorStyle: TextStyle(fontSize: 16.0),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (girilenDeger) {
                        if (girilenDeger.isEmpty) {
                          return "Şifre Alanı boş bırakılamaz!";
                        } else if (girilenDeger.trim().length < 4) {
                          return "Şifre 4 karakterden az olamaz!";
                        }
                        return null;
                      },
                      onSaved: (girilenDeger) => sifre = girilenDeger,
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _kullaniciOlustur,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // color: Theme.of(context).primaryColor,
                        // textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void _kullaniciOlustur() async {
    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);

    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        Kullanici kullanici = await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        if (kullanici != null) {
          FireStoreServisi()
              .kullaniciOlustur(id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        }
        Navigator.pop(context);

        //         Kullanici kullanici = await _yetkilendirmeServisi.mailIleKayit(email, sifre);
        // if(kullanici != null){
        //   FireStoreServisi().kullaniciOlustur(id: kullanici.id, email: email, kullaniciAdi: kullaniciAdi);
        // }
      } catch (hata) {
        // print("=>=>=>" + hata.code);
        setState(() {
          yukleniyor = false;
        });
        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "email-already-in-use") {
      hataMesaji = "Girdiğiniz mail kayıtlıdır";
    } else if (hataKodu == "weak-password") {
      hataMesaji = "Daha zor bir şifre tercih edin";
    }

    // Test

    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
