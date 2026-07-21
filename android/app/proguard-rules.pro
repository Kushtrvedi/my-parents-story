# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive
-keep class com.google.gson.** { *; }
-keep class hive.** { *; }
-keep class * extends org.apache.hadoop.hive.** { *; }

# speech_to_text
-keep class com.google.cloud.speech.** { *; }

# share_plus
-keep class dev.flutter.plusshare.** { *; }

# path_provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# flutter_tts
-keep class com.tundralabs.fluttertts.** { *; }

# Keep model classes
-keep class com.myparentsstory.my_parents_story.models.** { *; }

# General
-dontwarn javax.annotation.**
-dontwarn sun.misc.Unsafe
-keepattributes Signature
-keepattributes *Annotation*
