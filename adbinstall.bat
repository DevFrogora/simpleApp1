@echo off
adb devices > devices.txt

findstr /R /C:"device$" devices.txt > nul
pause 
if %errorlevel%==0 (
    echo Device found. Installing APK...
    adb install build\apk\MyApp-unsigned.apk
) else (
    echo No devices found. Connect a device and try again.
    rem or use below commands to restart adb server + turn off developer mode on device
    rem echo Restarting ADB server...
    rem adb kill-server
    rem adb start-server
    rem adb devices

)
pause 
del devices.txt

rem you can select the devices you want to install the apk on by using serial number
rem adb install -s <serial_number> build\apk\MyApp-unsigned.apk