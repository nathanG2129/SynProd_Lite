# Keep MLKit barcode scanning and common subpackages (fixes mobile_scanner's incomplete com.google.mlkit.* rule)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.gms.internal.mlkit_vision_barcode_bundled.** { *; }

# Keep CameraX and mobile_scanner plugin classes
-keep class androidx.camera.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Keep nsd Android plugin classes for local Wi-Fi mDNS discovery
-keep class com.haberey.flutter.nsd_android.** { *; }
