param (
    $TestName = "Test x",
    $Loops = 10,
    $Spawns = 50
)

# restore the project
Write-Host 
.\Restore.ps1

# create a script that re-runs the test with the same input parameters
".\Run-Tests.ps1 -TestName `"$testName`" -Loops $Loops -Spawns $Spawns" | Set-Content "ReRun-Tests.ps1"

"name, files, processes, threads" | Set-Content "./Results/$TestName/processes.csv"
"files, processes, threads" | Set-Content "./Results/$TestName/processes-bcc32c.csv"
"files, processes, threads" | Set-Content "./Results/$TestName/processes-bcc64.csv"
"files, processes, threads" | Set-Content "./Results/$TestName/processes-bcc64x.csv"

# time the original project
.\Run-Test.ps1 -testName $TestName -spawnCount 0

$stopwatch = [System.Diagnostics.Stopwatch]::new()
$stopwatch.Start()
# loop through {$loops} times adding {$spawns} number of files each time
for ($l = 1; $l -le $Loops; $l++) {
    # spawn the files
    .\Spawn.ps1 $Spawns
    # test the results
    Write-Host "Spawning build job(thread) Loop: $l, with $($l * $Spawns) files."
    $job = $TestName,$($Spawns * $l) | Start-Job -FilePath .\Run-Test.ps1

    while ($job.State -eq "Running") {
        # capture the bcc processes
        $process = Get-Process *bcc*
        if ($process) {
            $threadCount = ($process | select-object -ExpandProperty threads).count
            $name = $($process.Name.Split(' ')[0])
            $processCsvFile = "./Results/$TestName/processes-$name.csv"
            "$($l * $Spawns), $($process.Count), $threadCount" | Add-Content $processCsvFile
            $processCsvFile = "./Results/$TestName/processes.csv"
            "$name, $($l * $Spawns), $($process.Count), $threadCount" | Add-Content $processCsvFile
            Start-Sleep -Milliseconds 100
        }
    }
    Write-Host "Build job completed. State: $($job.State)"
}