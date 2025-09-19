plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${project.name}")

    // 🔹 Force Java 17 for ALL Android modules (apps + libraries)
    plugins.withType<com.android.build.gradle.BasePlugin> {
        project.extensions.findByName("android")?.let { ext ->
            when (ext) {
                is com.android.build.gradle.LibraryExtension -> {
                    ext.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                    ext.compileOptions.targetCompatibility = JavaVersion.VERSION_17
                }
                is com.android.build.gradle.AppExtension -> {
                    ext.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                    ext.compileOptions.targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }

    // 🔹 Force Kotlin JVM target
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "17"
    }
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
