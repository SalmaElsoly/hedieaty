
param (
    [string]$apkPath = ".\build\app\outputs\flutter-apk\app-debug.apk",
    [string]$testDriver = "test_driver/integration_test.dart",
    [string]$testTarget = "integration_test/app_test.dart",
    [string]$resultsDirectory = ".\integration_test_result",
    [string]$logFile = ".\integration_test_result\test_log.txt",
    [string]$recordedScreenFile = ".\integration_test_result\test_screen.mp4",
    [string]$genHtmlPath = "C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml"
)

# Wipe emulator data or uninstall app if installed
Write-Host "Wiping emulator data or uninstalling app if installed..."
try {
    adb shell pm list packages | Select-String -Pattern "package:com.example.hedieaty" > $null
    if ($?) {
        Write-Host "App is installed. Uninstalling..."
        adb uninstall com.example.hedieaty
    } else {
        Write-Host "App is not installed. Wiping emulator data..."
        adb emu kill
        Start-Sleep -Seconds 5
        adb start-server
    }
} catch {
    Write-Host "An error occurred while attempting to wipe the emulator data or uninstall the app."
}

# Create results directory if it does not exist
if (-Not (Test-Path -Path $resultsDirectory)) {
    New-Item -ItemType Directory -Path $resultsDirectory
}

if (-Not (Test-Path -Path $resultsDirectory)) {
    New-Item -ItemType Directory -Path $resultsDirectory
}


if (Test-Path -Path $logFile) {
    Remove-Item -Path $logFile
}
if (Test-Path -Path $recordedScreenFile) {
    Remove-Item -Path $recordedScreenFile
}
if (Test-Path -Path ".\coverage\html") {
    Remove-Item -Path ".\coverage\html" -Recurse
}


Write-Host "Installing APK on the connected device..."
adb install -r $apkPath


Write-Host "Initiating screen recording on the device..."
$screenRecordingJob = Start-Job -ScriptBlock {
    adb shell screenrecord /data/local/tmp/test_screen.mp4
}
Start-Sleep -Seconds 5


Write-Host "Running Flutter integration tests..."
try {
    flutter test --dart-define=FLUTTER_TEST=true --coverage integration_test/
} catch {
    Write-Host "Tests encountered errors. Check the log file for details."
}


Write-Host "Ending screen recording on the device..."
Stop-Job -Job $screenRecordingJob
Wait-Job -Job $screenRecordingJob
Start-Sleep -Seconds 5


Write-Host "Retrieving the recorded screen file from the device..."
adb pull /data/local/tmp/test_screen.mp4 $recordedScreenFile


Write-Host "Generating test coverage report..."
try {
    if (-Not (Test-Path -Path ".\coverage\html")) {
        New-Item -ItemType Directory -Path ".\coverage\html"
    }
    perl $genHtmlPath coverage/lcov.info --output-directory coverage/html
    Get-Content .\coverage\lcov.info | Out-File -FilePath $resultsDirectory\coverage_report.txt
} catch {
    Write-Host "Could not generate the coverage report. Check if genhtml is properly installed."
}


Write-Host "Cleaning up temporary files from the device..."
adb shell rm /data/local/tmp/test_screen.mp4

Write-Host "Test process completed! Logs, screen recording, and coverage reports are saved in $resultsDirectory"
