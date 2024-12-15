param (
    $TestName = "Test x",
    $Loops = 10,
    $Spawns = 50
)

function RunTest {
    param (
        $testName,
        $spawnCount
    )

    Write-Host "Running: $testName, $spawnCount"

    $path = "./Results/$TestName/"
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
    Write-Host "Completed: $testName, $spawnCount - bcc32: $b32c, bcc64: $b64c, bcc64x: $b64x`r`n"
}


# restore the project
Write-Host 
.\Restore.ps1

".\Run-Tests.ps1 -TestName `"$testName`" -Loops $Loops -Spawns $Spawns" | Set-Content "ReRun-Tests.ps1"

# time the original project
RunTest $TestName 0

# loop through {$loops} times adding {$spawns} number of files each time
for ($l = 1; $l -le $Loops; $l++) {
    # spawn the files
    .\Spawn.ps1 $Spawns
    # test the results
    RunTest $TestName $($Spawns * $l)
}