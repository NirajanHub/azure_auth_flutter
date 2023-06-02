import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD OAuth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AAD OAuth Home'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final Config config = new Config(
  //     "cc0ab738-09c1-45df-8aca-7c17c285b689",
  //     clientId,
  //     "openid offline_access",
  //     redirectURL);
  // final AadOAuth oauth = new AadOAuth(config);
  // await oauth.login();
  // String result = await oauth.getAccessToken();
  static final Config config = Config(
      policy: "b2c_1_signupsignin",
      isB2C: true,
      clientId: 'b776705b-29e9-4b80-9c5f-4ccee78a7fef',
      redirectUri: 'com.imaginecup.prodplatform://oauthredirect',
      tenant: "prodplatform",
      scope: 'openid',
      navigatorKey: navigatorKey,
      loader: const SizedBox());
  final AadOAuth oauth = AadOAuth(config);

  //  static final Config config = Config(
  //     policy: 'B2C_1A_SIGNUPORSIGNINWITHPHONE',
  //     responseType: 'code',
  //     codeChallenge: 'ZC6-VXwshHATQTYDwv-w6wthg4Smh78x12svNdXXs00',
  //     codeChallengeMethod: 'S256',
  //     clientId: 'd0c0d1b4-9510-47ed-9bbf-e7f7e530816c',
  //     redirectUri: 'https://jwt.ms',
  //     tenant: 'emlb2c.onmicrosoft.com',
  //     scope: 'openid https://emlb2c.onmicrosoft.com/0c0d1b4-9510-47ed-',
  //     navigatorKey: navigatorKey,
  //     loader: const SizedBox());
  // final AadOAuth oauth = AadOAuth(config);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'AzureAD OAuth',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.launch),
            title: const Text('Login${kIsWeb ? ' (web popup)' : ''}'),
            onTap: () {
              login(false);
            },
          ),
          if (kIsWeb)
            ListTile(
              leading: const Icon(Icons.launch),
              title: const Text('Login (web redirect)'),
              onTap: () {
                login(true);
              },
            ),
          ListTile(
            leading: const Icon(Icons.data_array),
            title: const Text('HasCachedAccountInformation'),
            onTap: () => hasCachedAccountInformation(),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(bool redirect) async {
    config.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
      (l) => showError(l.toString()),
      (r) => showMessage('Logged in successfully, your access token: $r'),
    );
    var accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(accessToken)));
    }
  }

  void hasCachedAccountInformation() async {
    var hasCachedAccountInformation = await oauth.hasCachedAccountInformation;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('HasCachedAccountInformation: $hasCachedAccountInformation'),
      ),
    );
  }

  void logout() async {
    await oauth.logout();
    showMessage('Logged out');
  }
}
