# Patch isar_flutter_libs Android build.gradle for AGP 8+ namespace requirement.
# Run once after `flutter pub get` (or when you see "Namespace not specified").
# Usage: .\scripts\patch_isar_android.ps1

$ErrorActionPreference = "Stop"
$pubCache = $env:PUB_CACHE
if (-not $pubCache) {
    $pubCache = Join-Path $env:LOCALAPPDATA "Pub\Cache"
}
$base = Join-Path $pubCache "hosted\pub.dev"
if (-not (Test-Path $base)) {
    Write-Error "Pub cache not found at $base"
}
$dirs = Get-ChildItem -Path $base -Directory -Filter "isar_flutter_libs*"
if ($dirs.Count -eq 0) {
    Write-Error "isar_flutter_libs not found. Run 'flutter pub get' first."
}
$targetDir = $dirs[0]
$buildGradle = Join-Path $targetDir.FullName "android\build.gradle"
if (-not (Test-Path $buildGradle)) {
    Write-Error "android/build.gradle not found at $buildGradle"
}
$content = Get-Content $buildGradle -Raw
# Replace conditional namespace with unconditional (required for AGP 8+)
$old = "if \(project\.android\.hasProperty\(""namespace""\)\) \{\s*namespace 'dev\.isar\.isar_flutter_libs'\s*\}"
$new = "namespace 'dev.isar.isar_flutter_libs'"
$patched = $content -replace $old, $new
if ($patched -eq $content) {
    # Maybe already patched or format differs; try adding namespace if missing
    if ($patched -notmatch "namespace\s+'dev\.isar\.isar_flutter_libs'") {
        $patched = $patched -replace "(\s*android\s*\{)\s*", "`$1`n    namespace 'dev.isar.isar_flutter_libs'`n    "
    }
}
if ($patched -eq $content) {
    Write-Host "No change made (already patched or format unknown). Content snippet:"
    Get-Content $buildGradle | Select-Object -First 35
    exit 0
}
Set-Content -Path $buildGradle -Value $patched -NoNewline
Write-Host "Patched: $buildGradle"
