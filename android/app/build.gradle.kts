import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Chargement des propriétés du keystore
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.guianou.chikabin"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.guianou.chikabin"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 8 // ✅ Incrémenté de 6 à 7
        versionName = "1.1.1"  // ✅ Incrémenté de 1.1.0 à 1.1.1
        multiDexEnabled = true

        // ✅ NOUVELLE SECTION - Désactive les permissions images/vidéos
        manifestPlaceholders["permissionHandlerReadMediaImages"] = "false"
        manifestPlaceholders["permissionHandlerReadMediaVideo"] = "false"
        manifestPlaceholders["permissionHandlerReadMediaAudio"] = "false"
    }

    // Configuration de signature (syntaxe Kotlin)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.0")
}
