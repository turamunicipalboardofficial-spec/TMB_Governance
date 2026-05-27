class Env {
  static const String _devBaseUrl = 'https://laravelv2.turamunicipalboard.com';
  static const String _prodBaseUrl = 'https://laravelv2.turamunicipalboard.com';

  static const bool isProduction = false;

  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;
}