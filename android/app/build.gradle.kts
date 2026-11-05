import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.src_kstu_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.kstu_src2.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 28
        versionName = "1.5.1"
    }

    // Load keystore properties from file
    val keystoreProperties = Properties().apply {
        val keystoreFile = rootProject.file("key.properties")
        if (keystoreFile.exists()) {
            load(keystoreFile.inputStream())
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true 
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    packagingOptions {
      jniLibs {
        // Compressed (legacy) packaging can't be page-aligned, which fails
        // Play Console's 16 KB memory page size requirement. Native libs
        // must be stored uncompressed so the OS can mmap them directly.
        useLegacyPackaging = false
      }
    }
}

flutter {
    source = "../.."
}
