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
    $bcc64time = Measure-Command { & .\build-bcc64.bat }
    $bcc64xtime = Measure-Command { & .\build-bcc64x.bat }

    "$spawnCount, $($bcc32time.TotalSeconds), $($bcc64time.TotalSeconds), $($bcc64xtime.TotalSeconds)" | Add-Content $file
    Write-Host "Completed: $testName, $spawnCount`r`n"
}


# restore the project
Write-Host 
.\Restore.ps1


# time the original project
RunTest $TestName 0

# loop through {$loops} times adding {$spawns} number of files each time
for ($l = 1; $l -le $Loops; $l++) {
    # spawn the files
    .\Spawn.ps1 $Spawns
    # test the results
    RunTest $TestName $($Spawns * $l)
}