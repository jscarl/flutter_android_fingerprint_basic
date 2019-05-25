import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Fingerprint'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }

  bool _isBiometricAvailable = false;
  String statusAuth;
  var localAuth = LocalAuthentication();

  Future<bool> checkBiometricAvailable() async{
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    return canCheckBiometrics;
  }

  Future<void> didAuthentication() async {
    try {
      const androidStrings = const AndroidAuthMessages(
        cancelButton: 'Batalkan',
        fingerprintNotRecognized: 'Fingerprint Gagal',
        fingerprintSuccess: 'Fingerprint Sukses',
        goToSettingsButton: 'Ke pengaturan',
        signInTitle: 'Masukkan fingerprint'
      );

      _isBiometricAvailable = await checkBiometricAvailable();

      print('_isBiometricAvailabel $_isBiometricAvailable');

      if(_isBiometricAvailable) {
        List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
        print('List $availableBiometrics');
        if(Platform.isAndroid) {
          if(availableBiometrics.contains(BiometricType.fingerprint)) {
            print('fingerprint ready');
            bool didAuthenticate = await localAuth.authenticateWithBiometrics(
              localizedReason: 'Aku butuh fingerprint kamu',
              // androidAuthStrings: androidStrings
            );

            if(didAuthenticate) {
              setState(() {
                statusAuth = 'berhasil';
              });
            }else {
              setState(() {
                statusAuth = 'Gagal';
              });
            }

            print('proses $didAuthenticate');
          }
        }
      }
      

    }on PlatformException catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hasil authentikasi dengan fingerprint',
            ),
            Text(
              '$statusAuth',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: didAuthentication,
        tooltip: 'Prees me!',
        child: Icon(Icons.fingerprint),
      ),
    );
  }
}
