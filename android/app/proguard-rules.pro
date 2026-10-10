# Zoom SDK
-keep class us.zoom.** { *; }
-keep interface us.zoom.** { *; }
-keep class com.zipow.** { *; }
-keep interface com.zipow.** { *; }
-keep class org.webrtc.** { *; }

# Missing optional classes
-dontwarn us.zoom.**
-dontwarn com.zipow.**
-dontwarn xcrash.**
-dontwarn com.microsoft.intune.**
-dontwarn javax.lang.model.**
-dontwarn kotlinx.parcelize.**
-dontwarn org.joda.time.**
-dontwarn retrofit2.**
-dontwarn io.reactivex.rxjava3.**
-dontwarn com.google.zxing.**

# JVM-only classes not used on Android
-dontwarn kotlinx.coroutines.swing.**
-dontwarn java.awt.**
-dontwarn javax.swing.**