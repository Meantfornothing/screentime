// FIX: Imports MUST be at the top of the script
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

// FIX: Define the task configuration before the main android block
tasks.withType<KotlinCompile>().configureEach {
    compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") 
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.screentime"
    compileSdk = flutter.compileSdkVersion
    
    ndkVersion = "27.0.12077973" 

    compileOptions {
        // FIX: Enable Core Library Desugaring
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    defaultConfig {
        applicationId = "com.example.screentime"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Ensure multiDex is enabled if not already (often needed with desugaring)
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// FIX: Add the desugaring dependency with the required version (2.1.4+)
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}