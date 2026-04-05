// 在文件最顶部添加
plugins {
    // 这一行是新加的，用来声明 Google Services 插件
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.android.application") apply false // 这里的版本号通常由 Flutter 自动管理，如果报错可以去掉 version
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
