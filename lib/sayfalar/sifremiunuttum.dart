import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class SifremiUnuttum extends StatefulWidget {
  @override
  _SifremiUnuttumState createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  final _formAnahtari = GlobalKey<FormState>();
  final _scaffoldAnahtari = GlobalKey<ScaffoldState>();
  bool yukleniyor = false;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldAnahtari,
        appBar: AppBar(title: Text("Şifremi Sıfırla")),
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
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sifreyiSifirla,
                        child: Text(
                          "Şifremi Sıfırla",
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

  void _sifreyiSifirla() async {
    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);

    var _formState = _formAnahtari.currentState;
    if (_formState.validate()) {
      _formState.save();

      setState(() {
        yukleniyor = true;
      });

      try {
        await _yetkilendirmeServisi.sifremiSifirla(email);
        Navigator.pop(context);
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

    if (hataKodu == "ERROR_INVALID_EMAIL") {
      hataMesaji = "Girdiğiniz mail adresi geçersizdir";
    } else if (hataKodu == "ERROR_USER_NOT_FOUND") {
      hataMesaji = "Bu mailde bir kullanıcı bulunmuyor";
    }

    var snackBar = SnackBar(content: Text(hataMesaji));
    _scaffoldAnahtari.currentState.showSnackBar(snackBar);
  }
}
