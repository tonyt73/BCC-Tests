param (
    $testName,
    $spawnCount
)

Write-Host "Running: $testName, $spawnCount"

$path = "$PSScriptRoot/Results/$TestName/"
$file = $path + "bcc-test.csv"

if ($spawnCount -eq 0) {
    # reset the CSV file
    New-Item -Path $path -ItemType Directory -Force -Confirm:$false -ErrorAction Ignore | Out-Null
    "files, bcc32, bcc64, bcc64x" | Set-Content $file
    # make a copy of the files used in the compile test, so we can recreate the test results if needed after the tests evolve over time
    $zip = @{
        Path = "bcc-test*.*", "unit*.*", "*.ps1", "*.bat"
        CompressionLevel = "Fastest"
        DestinationPath = $path + "files.zip"
    }
    Compress-Archive @zip -Force
}

# measure the time for each build
# swap the build time to negative if the executable is not present. ie. build failed
$bcc32time = Measure-Command { & .\build-bcc32.bat }
$b32c = 1
if (-not (Test-Path ".\Win32\Release\bcc-test.exe" -PathType Leaf)) {
    $b32c = -1
}

$bcc64time = Measure-Command { & .\build-bcc64.bat }
$b64c = 1
if (-not (Test-Path ".\Win64\Release\bcc-test.exe" -PathType Leaf)) {
    $b64c = -1
}

$bcc64xtime = Measure-Command { & .\build-bcc64x.bat }
$b64x = 1
if (-not (Test-Path ".\Win64x\Release\bcc-test.exe" -PathType Leaf)) {
    $b64x = -1
}

"$spawnCount, $($bcc32time.TotalSeconds * $b32c), $($bcc64time.TotalSeconds * $b64c), $($bcc64xtime.TotalSeconds * $b64x)" | Add-Content $file
#Write-Host "Completed: $testName, $spawnCount - bcc32: $b32c, bcc64: $b64c, bcc64x: $b64x`r`n"
