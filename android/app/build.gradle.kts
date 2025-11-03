// Android 앱을 빌드하기 위한 Gradle 설정 파일입니다
// Java 프로젝트의 build.gradle과 동일한 역할을 합니다
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.arduino_bluetooth_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.arduino_bluetooth_app"
        
        // 이 앱이 실행될 수 있는 최소 Android 버전입니다
        minSdk = 21
        
        // 이 앱이 테스트된 최신 Android 버전입니다
        targetSdk = 34
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
