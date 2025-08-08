# SHA1 Fingerprints for Firebase Console

## IMPORTANT: Add these SHA1 fingerprints to Firebase Console for Google Sign-In to work

### Release Keystore SHA1 (Production):
```
A2:AE:B8:F0:D3:5B:98:98:F8:BD:75:06:C8:E1:2F:AB:48:D9:30:5B
```

### Debug Keystore SHA1 (Development):
```
27:17:70:E6:1F:F4:71:E6:B5:C2:6D:D5:33:32:98:5C:DC:7F:75:E5
```

## Instructions:

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: healthai-0001
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps" section
5. Click on your Android app (com.yumie.healthai)
6. Scroll down to "SHA certificate fingerprints"
7. Click "Add fingerprint" and add BOTH SHA1 values above
8. Save the changes

After adding these fingerprints, Google Sign-In will work in both debug and release builds.

## Package Information:
- Application ID: com.yumie.healthai
- Release keystore: upload-keystore.jks (alias: upload)
- Debug keystore: ~/.android/debug.keystore (alias: androiddebugkey)
