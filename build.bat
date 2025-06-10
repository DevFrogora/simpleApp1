@echo off
setlocal

rem --- Configuration ---
set SDK_ROOT=C:\Users\root\AppData\Local\Android\Sdk

rem --- IMPORTANT: SET YOUR ANDROID SDK PATH HERE
set BUILD_TOOLS_VERSION=34.0.0
rem --- IMPORTANT: SET YOUR BUILD TOOLS VERSION HERE (e.g., 34.0.0, 33.0.0)
set API_LEVEL=android-34
 rem --- IMPORTANT: SET YOUR TARGET API LEVEL HERE (e.g., android-34, android-33)

set PLATFORM_TOOLS="%SDK_ROOT%\platform-tools"
set BUILD_TOOLS=%SDK_ROOT%\build-tools\%BUILD_TOOLS_VERSION%
set PLATFORM_JAR=%SDK_ROOT%\platforms\%API_LEVEL%\android.jar

rem --- Output Directories ---
set OUT_DIR=build
set GEN_DIR=%OUT_DIR%\gen
set OBJ_DIR=%OUT_DIR%\obj
set DEX_DIR=%OUT_DIR%\dex
set APK_DIR=%OUT_DIR%\apk



rem --- Cleanup ---
echo Cleaning up...
rd /s /q %OUT_DIR%


mkdir %GEN_DIR% %OBJ_DIR% %DEX_DIR% %APK_DIR%



rem --- 1. Generate R.java (Resource IDs) ---
echo Generating R.java...
echo %BUILD_TOOLS%

"%BUILD_TOOLS%\aapt.exe" package -f -m -J "%GEN_DIR%" -S res -I "%PLATFORM_JAR%" -M AndroidManifest.xml

rem --- 2. Compile Java Source Code ---
echo Compiling Java code...
set JAVASRC_DIR=src\main\java
dir /s /b "%JAVASRC_DIR%\*.java" > "%OUT_DIR%\sources.txt" rem List all .java files

echo %PLATFORM_JAR%

javac -source 1.8 -target 1.8 ^
    -bootclasspath "%PLATFORM_JAR%" ^
    -d "%OBJ_DIR%" ^
    -s "%GEN_DIR%" ^
    @"%OUT_DIR%\sources.txt" ^
    "%GEN_DIR%\com\example\myapp\R.java"

if %errorlevel% neq 0 (
    echo Java compilation failed.
    goto :eof
)

pause
rem --- 3. Convert .class to .dex (Dalvik Executable) ---
echo %BUILD_TOOLS%
echo %DEX_DIR%
echo %OBJ_DIR%
echo Converting .class to .dex...

"%BUILD_TOOLS%\d8.bat" --lib "%PLATFORM_JAR%" --output "%DEX_DIR%" "%OBJ_DIR%\*.class"
pause
rem call C:\Users\root\AppData\Local\Android\Sdk\build-tools\34.0.0\d8.bat --lib "C:\Users\root\AppData\Local\Android\Sdk\platforms\android-34\android.jar" --output "build\dex" build\obj\com\example\myapp\*.class
if %errorlevel% neq 0 (
    echo DEX conversion failed.
    goto :eof
)
pause
rem --- 4. Package Resources and DEX into an Unsigned APK ---
echo Packaging unsigned APK...
"%BUILD_TOOLS%\aapt.exe" package -f -M AndroidManifest.xml -S res -I "%PLATFORM_JAR%" -F "%APK_DIR%\MyApp-unsigned.apk" "%DEX_DIR%"

if %errorlevel% neq 0 (
    echo APK packaging failed.
    goto :eof
)

rem --- 5. Generate Keystore (if not exists) ---
set KEYSTORE="my-release-key.keystore"
set KEY_ALIAS="mykeyalias"
if not exist %KEYSTORE% (
    echo Generating new keystore: %KEYSTORE%
    keytool -genkey -v -keystore %KEYSTORE% -alias %KEY_ALIAS% -keyalg RSA -keysize 2048 -validity 10000 ^
        -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown" ^
        -storepass password -keypass password
    if %errorlevel% neq 0 (
        echo Keystore generation failed.
        goto :eof
    )
)

rem --- 6. Sign the APK ---
echo Signing the APK...
rem For API level 24 and higher, use apksigner (recommended)
"%BUILD_TOOLS%\apksigner.bat" sign --ks %KEYSTORE% --ks-key-alias %KEY_ALIAS% --ks-pass pass:password --key-pass pass:password "%APK_DIR%\MyApp-unsigned.apk"
if %errorlevel% neq 0 (
    echo APK signing failed.
    goto :eof
)
move "%APK_DIR%\MyApp-unsigned.apk" "%APK_DIR%\MyApp-signed.apk"

echo Build complete! APK: %APK_DIR%\MyApp-signed.apk
echo To install: adb install %APK_DIR%\MyApp-signed.apk
echo To uninstall: adb uninstall com.example.myapp
endlocal