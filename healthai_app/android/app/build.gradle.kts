plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.yumie.healthai"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
        freeCompilerArgs += listOf("-Xjvm-default=all")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.yumie.healthai"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        // Note: Do not set ndk.abiFilters when building with --split-per-abi
    }

    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = "yumiemaivenx"
            keyAlias = "upload"
            keyPassword = "yumiemaivenx"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            ndk {
                // Generate native debug symbols zip for Play Console
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }

    lint {
        disable += "InvalidPackage"
    }

    // Use standard symbol stripping; symbols are exported separately via ndk.debugSymbolLevel
}

dependencies {
    // Import the BoM for the Firebase platform (pinned to a version compatible with Kotlin 1.9.x)
    implementation(platform("com.google.firebase:firebase-bom:33.6.0"))
    
    // Add Firebase dependencies (versions managed by BoM)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-functions")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-config")
    
    // Add other dependencies
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Play Integrity API - Updated to latest version
    implementation("com.google.android.play:integrity:1.4.0")
    
    // Coroutines for async operations
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.7.3")
    
    // Google Play Billing Library
    implementation("com.android.billingclient:billing-ktx:6.2.1")
    
    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")

}
