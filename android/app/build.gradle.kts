// FIX 2 (REVISED): Correct, non-deprecated way to set Kotlin JVM target in KTS
// This applies the jvmTarget flag directly to the Kotlin compilation tasks.

// FIX: Imports MUST be at the top of the script, not at the end.
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

// FIX: Define the task configuration before the main android block
// FIX: Using compilerOptions DSL inside tasks.withType to resolve the error.
tasks.withType<KotlinCompile>().configureEach {
    // FIX: Removed 'kotlinOptions.' prefix to correctly access compilerOptions directly on the task.
    compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") 
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.screentime"
    compileSdk = flutter.compileSdkVersion
    
    // FIX 1: Removed the duplicated assignment operator ("ndkVersion = ")
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // FIX 2 REMOVED: The problematic kotlinOptions block that caused the Unresolved Reference error is removed from here.
    
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.screentime"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}