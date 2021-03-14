import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/sayfalar/akis.dart';
import 'package:socialapp/sayfalar/ara.dart';
import 'package:socialapp/sayfalar/duyurular.dart';
import 'package:socialapp/sayfalar/profil.dart';
import 'package:socialapp/servisler/yetkilendirmeservisi.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  int _aktifSayfaNo = 0;
  PageController sayfaKumandasi;

  @override
  void initState() {
    super.initState();
    sayfaKumandasi = PageController();
  }

  @override
  void dispose() {
    sayfaKumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false).aktifKullaniciId;

    return Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(), // Asla Kaydırılamaz Özelliği
          onPageChanged: (acilanSayfaNo) {
            setState(() {
              _aktifSayfaNo = acilanSayfaNo;
            });
          },
          controller: sayfaKumandasi,
          children: [
            Akis(),
            Ara(),
            // Yukle(),
            Duyurular(),
            Profil(profilSahibiId: aktifKullaniciId),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          currentIndex: _aktifSayfaNo,
          iconSize: 25.0,
          selectedColor: Color(0xff040307),
          strokeColor: Color(0x30040307),
          unSelectedColor: Color(0xffacacac),
          backgroundColor: Colors.white,
          items: [
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.home),
            ),
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidCompass),
            ),
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidBell),
              badgeCount: 0,
              showBadge: true,
            ),
            CustomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.solidUserCircle),
            ),
          ],
          onTap: (secilenSayfaNo) {
            sayfaKumandasi.jumpToPage(secilenSayfaNo);
          },
        )
        // bottomNavigationBar: BottomNavigationBar(
        //   currentIndex: _aktifSayfaNo,
        //   selectedItemColor: Colors.black87,
        //   unselectedItemColor: Colors.grey[600],
        //   // iconSize: 25.0,
        //   // fixedColor: Colors.blue,
        //   // selectedFontSize: 25.0,
        //   // unselectedFontSize: 25.0,
        //   backgroundColor: Colors.red,
        //   type: BottomNavigationBarType.fixed,
        //   items: [
        //     BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.home), label: ""),
        //     BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidCompass), label: ""),
        //     // BottomNavigationBarItem(icon: Icon(Icons.file_upload), label: "Yükle"),
        //     BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidBell), label: ""),
        //     BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.solidUser), label: ""),
        //     // BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        //     // BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
        //     // // BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ""),
        //     // // BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
        //     // BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        //   ],
        //   onTap: (secilenSayfaNo) {
        //     setState(() {
        //       sayfaKumandasi.jumpToPage(secilenSayfaNo);
        //     });
        //   },
        // ),
        );
  }
}
