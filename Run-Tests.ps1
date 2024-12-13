function RunTest {
    param (
        $spawnCount
    )

    $bcc32time = Measure-Command { & .\build-bcc32.bat }
    $bcc64time = Measure-Command { & .\build-bcc64.bat }
    $bcc64xtime = Measure-Command { & .\build-bcc64x.bat }

    if ($spawnCount -eq 0) {
        # reset the CSV file
        "files, bcc32, bcc64, bcc64x" | Set-Content "bcc-test.csv"
    }

    "$spawnCount, $($bcc32time.TotalSeconds), $($bcc64time.TotalSeconds), $($bcc64xtime.TotalSeconds)" | Add-Content "bcc-test.csv"
}


# restore the project
Write-Host 
.\restore.ps1

# loop through {$loops} times adding {$spawns} number of files each time
$loops = 10
$spawns = 50

# time the original project
RunTest 0

for ($l = 1; $l -le $loops; $l++) {
    # spawn the files
    .\spawn.ps1 $spawns
    # test the results
    RunTest $($spawns * $l)
}