plugins {
    
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
   
}



android {
    namespace = "com.example.dog_book"
    compileSdk = 35  // Explicitly set this instead of using flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Updated as required by plugins

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Updated to 17
        targetCompatibility = JavaVersion.VERSION_17  // Updated to 17
        coreLibraryDesugaringEnabled = true  // Added for desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Updated to 17
    }

    defaultConfig {
        applicationId = "com.example.dog_book"
        minSdk = 23  // Explicitly set this instead of using flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // Added for multidex support
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Add this for Java 8+ features on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Add multidex support
    implementation("androidx.multidex:multidex:2.0.1")

    // implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // implementation("com.google.firebase:firebase-analytics")
    /////////////////////////////
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}