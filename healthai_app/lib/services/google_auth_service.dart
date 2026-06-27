import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class GoogleAuthService {
  static const String _scope =
      'https://www.googleapis.com/auth/androidpublisher';

  static const String _serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "yumie-maivenx02",
  "private_key_id": "fd9f1403258e7268ba214a08d5210d2a31f22b90",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC6VQ9lFB3qsc83\\nOubl1RGK+Gw/v/+WVzYl+VY8gvmEm4zSNvg7mG7vbeEgpM7eGC9tXx4s2WBGFG2K\\nNimDqv7lBP2mvYcpnEIoMFRiSpSBoO+RIS5h0z5HuFrtoMED0E6eYOJCSBMDwpQq\\nnNAhxakcBg2Dk//e58KEf2trTLQ+NQkE6qikCtT/yKLoHNdoeEklK5A+BXYKvdR/\\njJoVR4qulcF8DkwkR44m+cx6ndj2/eTqLgYoQkPHaTg4qeHOJUjnVO6TcHQw3bDX\\nMcPlAiEk3QtKNNXi6GbI0g+ZFFqAjkJc0Rg+yEsahB+dLxJs/AHq0wINUrqmKi+f\\nq9a4nkGfAgMBAAECggEAGgVG4RauFtg917iiBfZ7PKz0cPKe/p+vMB5hrJGdxqby\\nQ2jpwWjIFSeDCMv7F4jJFrzxudGhYCf6JBLsOTbn4ZOQ2HgfJ/BqTLJzFkbT9kZD\\nLkEz+PVG/T0Bda29RosQb42YCymFfkDt8AV2C0FPHFq8CGPil35F67rfhVxwzz7b\\nhjjD1CWzNZw6didkGz7ru5MuscOnfQymrLoYU1q6rEQrEqgiN9PcIanqTAphlSvj\\nDeY7w38CDLPm9HPYLsZH2RfRZjY6qDJcIvn/6JiqAFKfGwRnPBwchGnjU6H62e3B\\nyMWSxAVlGcOIF1LNGAqeSbruo/3Da60suvsujIP4AQKBgQDupGtHV0ehlfupQ6VJ\\noN3guDSusYtFzm3iDxDKP/kpN75TgmM2tyDBYy9N5pL6ktT5MRb5zGSonojo9eg8\\nwouuTuADpnd+WkdlK1+kxMYnIOmJAx98zrE+fFki6D8ZBNFL4FSdSi+nlJgYSy6k\\nHcB99vGH83qtd6a+pVY3Ftr8cQKBgQDH4p2IUsL+u7fwLV3Bnz0fLlZeuZ1JR2Kj\\n2vrGgYdGaler/oBuCveyNGeyxnwqfNiULTGhkbfbR5dBmbohZEIlWrQtN/Krlquo\\nKk514OO8cwnnCwNiBAKNbk6jXItzuUJ0EN4r6vgo6tPPEpeUfuelZb+tJuxue+xh\\niG9QpbhnDwKBgQDrNk2ytFka7+xrSgxZBOCMRKNQaBhAxpVRkc3XurRHpvTF9Kb7\\nYAY99hfC7XeC2ERoFLVzory34gJJs06izJHGTWHI10PB2xOxqM2NZpF0MaFc9SIM\\n7uCOGRv2JvlCHJh58/MSUPOldfVvRHMFOXnn7gTkHdyVq3BDSk0u4S0YUQKBgQCf\\nmSn/d1WK34f2lcKOnv7GrtD3wWz83aq8+lPRvAqvBqoKAqO5Obic6YsDC8iIhDbJ\\n2WwPfbI3u+nhz0T29H58JPhIQqvYpe1Z0K3lITO1fIUjnX+N+3WuR60ycupF9F5D\\nHlTG7E5JHXcRl97ACrQbNCrfrnyJmxkapz16P1gFsQKBgAzG2i6jqgaPRFzgDGrU\\nh8I+f2sOhUFWBtDkSeG5AXeTdsZVBmnUKJdHxsnds+yQzKpNYYXCk/qa21Qqouqy\\ntA9w4tUZy+TN+a0QDBmyqvKuRH6ikBOOnu2IgfsAOXHrzWkEnfoqczHRJp4277lt\\nDBLDf54VDBknpQpzQ5RxQW+A\\n-----END PRIVATE KEY-----\\n",
  "client_email": "play-validation-service@yumie-maivenx02.iam.gserviceaccount.com",
  "client_id": "100360698538289552374",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/play-validation-service%40yumie-maivenx02.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}''';

  static Future<String> getAccessToken() async {
    final credentials = ServiceAccountCredentials.fromJson(_serviceAccountJson);
    final client = http.Client();

    try {
      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        credentials,
        [_scope],
        client,
      );

      return accessCredentials.accessToken.data;
    } finally {
      client.close();
    }
  }
}
