import java.security.KeyStore
import java.security.cert.X509Certificate

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Supply secrets through private Gradle properties or the build environment.
// Never generate keys here or use the debug certificate for release artifacts.
fun releaseValue(property: String, environment: String): String? =
    providers.gradleProperty(property).orNull?.takeIf { it.isNotBlank() }
        ?: providers.environmentVariable(environment).orNull?.takeIf { it.isNotBlank() }

val releaseApplicationId = releaseValue("davochainApplicationId", "DAVOCHAIN_APPLICATION_ID")
val releaseStoreFile = releaseValue("davochainStoreFile", "DAVOCHAIN_STORE_FILE")
val releaseStorePassword = releaseValue("davochainStorePassword", "DAVOCHAIN_STORE_PASSWORD")
val releaseKeyAlias = releaseValue("davochainKeyAlias", "DAVOCHAIN_KEY_ALIAS")
val releaseKeyPassword = releaseValue("davochainKeyPassword", "DAVOCHAIN_KEY_PASSWORD")
val releaseConfigured = listOf(releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword)
    .all { it != null }

val validateProductionIdentity = tasks.register("validateProductionIdentity") {
    doLast {
        val applicationId = releaseApplicationId
        check(applicationId != null &&
            applicationId != "com.example.davochain" &&
            !applicationId.startsWith("com.example.") &&
            Regex("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+").matches(applicationId)) {
            "Production release requires a managed davochainApplicationId / DAVOCHAIN_APPLICATION_ID."
        }
        check(releaseConfigured) {
            "Production signing requires store file, store password, key alias and key password via davochain Gradle properties or DAVOCHAIN environment variables."
        }
        check(file(releaseStoreFile!!).isFile) { "Production signing store is unavailable." }
        check(file(releaseStoreFile!!).name != "debug.keystore" &&
            !releaseKeyAlias.equals("androiddebugkey", ignoreCase = true)) {
            "Production release cannot use the Android debug signing identity."
        }
        val store = KeyStore.getInstance(file(releaseStoreFile!!), releaseStorePassword!!.toCharArray())
        val certificate = store.getCertificate(releaseKeyAlias) as? X509Certificate
        check(certificate != null &&
            !certificate.subjectX500Principal.name.contains("CN=Android Debug", ignoreCase = true)) {
            "Production release requires a non-debug signing certificate."
        }
    }
}

tasks.configureEach {
    if (name.contains("Release") && name != "validateProductionIdentity") {
        dependsOn(validateProductionIdentity)
    }
}

android {
    namespace = "com.example.davochain"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = releaseApplicationId ?: "com.example.davochain"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseConfigured) {
            create("production") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseConfigured) signingConfigs.getByName("production") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
