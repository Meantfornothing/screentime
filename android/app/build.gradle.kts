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
    namespace = "com.example.screentime"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Ensure this matches your installed NDK

    compileOptions {
        // 3. Enable Desugaring for Java 8+ features on older Androids
        isCoreLibraryDesugaringEnabled = true
        
        // 4. Set Java Compatibility to 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Kotlin options block removed in favor of tasks.withType above to avoid deprecation errors

    defaultConfig {
        applicationId = "com.example.screentime"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 5. Enable MultiDex
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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