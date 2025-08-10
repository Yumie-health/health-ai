## Keep Firebase Analytics and Google Services models
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

## Keep Play Billing client models used via reflection
-keep class com.android.billingclient.** { *; }

## Keep Flutter JNI
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

## Keep Play Core split install classes referenced by Flutter deferred components
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

## Keep SplitCompatApplication subclasses if present
-keep class **.SplitCompatApplication { *; }

## Keep Retrofit/OkHttp/JSON models if used
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**


