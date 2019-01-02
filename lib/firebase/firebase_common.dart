import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

String _idToken;

String get token => _idToken;

set(String token) => _idToken = token;

Map<String, FirebaseApp> _apps = Map();


class FirebaseApp {

  FirebaseApp({@required this.name, @required this.options}) : assert(name != null), assert(options != null);

  /// The name of this app.
  final String name;

  static final String defaultAppName =
  Platform.isIOS ? '__FIRAPP_DEFAULT' : '[DEFAULT]';

  final FirebaseOptions options;

  static Future<FirebaseApp> configure({
    @required String name,
    @required FirebaseOptions options,
  }) async {
    assert(name != null);
    assert(name != defaultAppName);
    assert(options != null);
    assert(options.googleAppID != null);
    final FirebaseApp existingApp = await FirebaseApp.appNamed(name);
    if (existingApp != null) {
      assert(await existingApp.options == options);
      return existingApp;
    }

    FirebaseApp app = FirebaseApp(name: name, options: options);
    _apps.putIfAbsent(name, () => app);

    return app;
  }

  static Future<FirebaseApp> appNamed(String name) async {
    return _apps != null ? _apps[name] : null;
  }
}

class FirebaseOptions {
  const FirebaseOptions({
    this.apiKey,
    this.bundleID,
    this.clientID,
    this.trackingID,
    this.gcmSenderID,
    this.projectID,
    this.androidClientID,
    @required this.googleAppID,
    this.databaseURL,
    this.deepLinkURLScheme,
    this.storageBucket,
  }) : assert(googleAppID != null), assert(projectID != null);

  /// An API key used for authenticating requests from your app, e.g.
  /// "AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk", used to identify your app to
  /// Google servers.
  ///
  /// This property is required on Android.
  final String apiKey;

  /// The iOS bundle ID for the application. Defaults to
  /// `[[NSBundle mainBundle] bundleID]` when not set manually or in a plist.
  ///
  /// This property is used on iOS only.
  final String bundleID;

  /// The OAuth2 client ID for iOS application used to authenticate Google
  /// users, for example "12345.apps.googleusercontent.com", used for signing in
  /// with Google.
  ///
  /// This property is used on iOS only.
  final String clientID;

  /// The tracking ID for Google Analytics, e.g. "UA-12345678-1", used to
  /// configure Google Analytics.
  ///
  /// This property is used on iOS only.
  final String trackingID;

  /// The Project Number from the Google Developer’s console, for example
  /// "012345678901", used to configure Google Cloud Messaging.
  ///
  /// This property is required on iOS.
  final String gcmSenderID;

  /// The Project ID from the Firebase console, for example "abc-xyz-123."
  final String projectID;

  /// The Android client ID, for example "12345.apps.googleusercontent.com."
  ///
  /// This property is used on iOS only.
  final String androidClientID;

  /// The Google App ID that is used to uniquely identify an instance of an app.
  ///
  /// This property cannot be `null`.
  final String googleAppID;

  /// The database root URL, e.g. "http://abc-xyz-123.firebaseio.com."
  ///
  /// This property should be set for apps that use Firebase Database.
  final String databaseURL;

  /// The URL scheme used to set up Durable Deep Link service.
  ///
  /// This property is used on iOS only.
  final String deepLinkURLScheme;

  /// The Google Cloud Storage bucket name, e.g.
  /// "abc-xyz-123.storage.firebase.com."
  final String storageBucket;
}