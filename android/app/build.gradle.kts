// 1. Imports at the top
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 2. Configure Kotlin Tasks
tasks.withType<KotlinCompile>().configureEach {
    compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
}

android {
    // 1. Correct namespace for your current "screentime" project
    namespace = "com.example.screentime"
    compileSdk = flutter.compileSdkVersion
    
    // 2. Updated to r28 for better 16KB page support (Recommended for 2026)
    ndkVersion = "28.0.12674087" 

    compileOptions {
        // Required for using modern Java features (like Streams) on older Android versions
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.screentime"
        
        // Ensure these use the properties provided by the Flutter Gradle Plugin
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Native multidex is active for minSdk 21+, so this is optional
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // Standard debug-key signing for development; change for production!
            signingConfig = signingConfigs.getByName("debug")
            
            // Realign-specific: Enable shrinking for better performance
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    // 6. Use the newer desugaring library version required by flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}