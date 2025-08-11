import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class GoogleAuthService {
  static const String _scope = 'https://www.googleapis.com/auth/androidpublisher';
  
  static const String _serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "healthai-0001",
  "private_key_id": "905694381242927f4a99c129f328390b1eb0fead",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDS/RU/Ne1tT7hl\\nuqNiQqb8OUf6gy72g2OfwhtNGRQ8tlPWCUIw1VQlSu5evDu1BaPZmUhR6w+64+AG\\nCxiefEbwWntnbcXI/qoPICfIPdGgzopU4BVmA664MOZt9EYswSKmXy9tDCDiRMIW\\nv98WfcnGLTye5tUkhsh9UUfkCHSbM0lnTvAVYCJrsawIHHdJS/Pt49pu8oxbyOqI\\nWpyjIdgkZrXEj66o9zk6ZGlbFZj8YGXujX6pbh0cKuSplZllGa/cEip/YCW6A6xj\\nZ3mZif+JmdFoO4IG2pmCOLubHmSPe6UkFzsFm0k2j1lce845HFKidjem8hq+trud\\noq9YHAXzAgMBAAECggEAPkBm6vIV3glF/lnth/njfArIlnzrN9e3ZrUmSf6qzmj7\\nXmz35yGiRKiRoUkHktcZq4PC50ykJP/EIvRWLLi9U4BW5cLpNu8QrQrPQhEfT0Nx\\nZC6DkchnXjgrXOjUZbMMbqsp+pI4B5rC62RsRZ4SkRLazoWMAM11zSfUvs7R3NJh\\nGqnNbSdcF+DYj1CBcTxELcs658lvYbu+g5y75Rtkkm460Pi/DwCtAHVs/pwRQuwV\\nmMDtMz6NwEf6sttely8lBJ6Ef44ey7ch2V1Wvq0Hyo+6FNGTtAdN095FLwn6i7bx\\nUxmrnBnuH1chLM2sxN/Reu8Zn81jO/P7kFlvqFxLtQKBgQD3xRonecRagtgULCEV\\n89rs86XbpscE38pn4SD6j7MS+2NXOe2dXAN6Ml3flRZb7av+WGghhIvz8hU6Cy72\\nDlNAQvF0SIMJeKTU1eu36XfiaKgE/TYusX+eXMIUtvEaVSX5/E3LfzKN5XKZfXXx\\ntvvc1I5dFToZ16SANCT+IC2ujQKBgQDZ/zZ/NdJZguHjbTVnflCXoov9zU8YGcOh\\n34jqgMxKIWxQMbYJ3Q0cy9kApdhDk/CGDVTmXA+k6Cgs14AwvwtG80Xpkyp5xc9T\\n/qLvxEN2n+HALYQVhKVQgq+jsKC9ylZy/MyY10zXIPwD7aCzGGx8/xn9aoYf0y0q\\nwmYeqA+mfwKBgClQhHvwof01tDIo6ZtvfiHkvtNRi/4UEvwfXhBpxcJ0iKwSzLxg\\ni3Pk0iJmCcRqbTOMKlDseSnERCXZl4sP+HHOt9RcAv2hUFrtENEp7QOjz+CFGHPQ\\nxSby8Knjl3B8okh8+bvlCdj/WYyejvwvNvArwVFkKLwGaTe3ejOlyfhBAoGAZBDN\\ncDlBdEsq611e7UHDNserYPZUPyjcbzqPu60hmUmcUXdwKzjn4vcDhlOaYPLQrogC\\nF7fcioLyphrJwhZ/07Kpvd0K21jcoZ66Jjs+CH69fpymC8aWp81FWGskbdoqMqAu\\nPl5d7EY8yITUhkFI01u6D2RNauBh1EXl4F6eyHsCgYEAwROCXXaioCH9ZV+n08yg\\n0Ske2M4909NfT8oLZmDnJmmOWpicJDFaWRRHxPmrS2YNe1U/IJ8DkIRn8ubnm4pp\\nFZFB5UPfg3RUU+Wjz0fCZC8/qNa0fTxl0854V7UXsxXUEVDA625Ic6AQphnqsXdv\\nE4FeK1kyo3VOgSuwe9hnutU=\\n-----END PRIVATE KEY-----\\n",
  "client_email": "play-validation-service@healthai-0001.iam.gserviceaccount.com",
  "client_id": "109223228760563251381",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/play-validation-service%40healthai-0001.iam.gserviceaccount.com",
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
