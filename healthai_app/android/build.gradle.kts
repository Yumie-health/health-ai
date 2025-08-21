plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
    // Kotlin plugin will be provided via buildscript classpath
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.12.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.21")
    }

    // Force any subproject buildscript classpaths to use Kotlin 2.1.21
    configurations.classpath { 
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.1.21")
                because("Align Kotlin toolchain across all included builds")
            }
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Ensure all runtime/compile configurations use Kotlin 2.1.21 artifacts
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.1.21")
                because("Force Kotlin stdlib/compiler embeddables to 2.1.21 to match plugin")
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

