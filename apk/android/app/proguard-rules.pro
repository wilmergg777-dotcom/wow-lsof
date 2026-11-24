# AstroIO — reglas R8/ProGuard
# La app no usa librerías externas; R8 ofusca todo lo posible.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# No ofuscar los nombres usados por reflexión del sistema (WebViewClient, etc. se resuelven solos).
-dontwarn android.webkit.**
