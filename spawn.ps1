param (
    [Int32]$Spawn
)

Set-Location $PSScriptRoot

function FindSection {
    param (
        [String[]]$Lines,
        [String]$Match
    )

    $inMatch = $false
    $section = @();
    foreach ($line in $Lines) {
        $tline = $line.Trim()
        if ($tline.StartsWith("<") -and $tline.Contains($Match)) {
            $inMatch = $true
        }
        if ($inMatch) {
            $section += $line
            $inMatch = $inMatch -and -not $tline.StartsWith("</") -and -not $tline.EndsWith("/>")
        }
        if (-not $inMatch -and $section.Length -gt 0) {
            break
        }
    }
    return $section
}

function FindLine {
    param (
        [String[]]$Lines,
        [String]$Match
    )

    for ($i = 0; $i -lt $Lines.Length; $i++) {
        if ($Lines[$i].Trim() -eq $Match) {
            return $i
        }
    }

    return 0
}

function CopyFile {
    param (
        [String]$Line,
        [String]$newNo
    )

    $file = ""
    if ($line.Contains(".")) {
        if ($line.Contains("`"")) {
            $file = $line.Split("`"")[1]
        } elseif ($line.Contains(">")) {
            $file = $line.Split(">")[1].Split("<")[0]
        }

        if ($file -ne "") {
            # make a copy of the original file
            $nf = $file.Replace("000", $newNo)
            Write-Host "Copying file: '$file' as '$nf'"
            Copy-Item -Path $file -Destination $nf
            # load the file and change the class references
            (Get-Content $nf).Replace("000", "$no") | Set-Content $nf
        } else {
            Write-Error "File not found: $file"
        }
    }
}

function Spawn {
    param (
        [String[]]$Lines,
        [Int32]$FromNo,
        [Int32]$Count
    )

    $newLines = @()
    $spc = 0
    $base =($FromNo / 1000) * 1000
    $FromNo %= 1000
    
    for ($c = 1; $c -le $Count; $c++) {
        if ($c + $FromNo -lt 1000) {
            $tlines = @()
            $tlines = $tlines + $Lines
            $nx = $base + $FromNo + $c
            $no = "000" + $nx
            $no = $no.Substring($no.Length-3, 3)
            # get the files to spawn from the lines and create them with the new spawn number
            for ($i = 0; $i -lt $tlines.Length; $i++) {
                $tlines[$i] = $tlines[$i].Replace("000", $no)
                if ($tlines[$i] -ne $Lines[$i]) {
                    CopyFile $Lines[$i] $("000".Replace("000", $no))
                }
            }
            $newLines = $newLines + $tlines
        } else {
            $spc = 1000 - ($FromNo + $Count)
            break;
        }
    }
    if ($spc -gt 1000) {
        Write-Error "Spawn count exceeded 1000, skipped $FromNo + $Count - 1000 = $spc."
    }

    return $newLines
}

if ($Spawn -le 1000) {

    # load in Project1.cbproj
    $projectFile = Get-Content "bcc-test.cbproj"
    # find the <CppCompile Include="Unit1000.cpp"> section
    $unit1Section = FindSection $projectFile 'CppCompile Include="Unit1000.cpp"'
    #  and the <FormResources Include="Unit1000.dfm"/> section
    $unit1FrmRes = FindSection $projectFile 'FormResources Include="Unit1000.dfm"'
    
    # find the <CppCompile Include="Unit2000.cpp"> section
    # spawn <n> more copies of unit1.cpp/dfm/h and unit2.cpp/h and add them to the project file
    $unit2Section = FindSection $projectFile 'CppCompile Include="Unit2000.cpp"'

    # find the line we need to start adding file references to
    $baseAt = [Int32](FindLine $projectFile '<BuildConfiguration Include="Base">')
    $frmrAt = [Int32](FindLine $projectFile '<FormResources Include="Unit1000.dfm"/>')

    # get the line before the insertAt position as it should have the number we need to start spawning from
    $spawnFromNo = [Int](($projectFile[$baseAt-1].Split("`"")[1].Replace("Unit","").Replace(".dfm","")) - 1000)

    $u1ss = Spawn $unit1Section $spawnFromNo $Spawn
    $u1fr = Spawn $unit1FrmRes $spawnFromNo $Spawn
    $u2ss = Spawn $unit2Section ($spawnFromNo+1000) $Spawn

    # new add the new lines to the project file
    $p1 = $frmrAt - 1
    $p2 = $frmrAt
    $p3 = $frmrAt + 1
    $newProjectFile = $projectFile[0..$p1] + $u1ss + $u2ss + $projectFile[$p2] + $u1fr + $projectFile[$p3..$projectFile.Length]
    $newProjectFile -Join ("`r`n") | Set-Content "bcc-test.cbproj"

    #update the project cpp file
    $cppFile = Get-Content ".\bcc-test.cpp"
    $useformLine = FindLine $cppFile 'USEFORM("Unit1000.cpp", Form1000);'
    $lines = @()
    for ($i = 1; $i -le $Spawn; $i++) {
        $nx = 1000 + $spawnFromNo + $i
        $line = 'USEFORM("Unit1000.cpp", Form1000);'.Replace("1000", "$nx")
        $lines += $line
    }
    $nl = $useformLine+1
    $newCppFile = $cppFile[0..$useformLine] + $lines + $cppFile[$nl..$cppFile.Length]
    $newCppFile | Set-Content ".\bcc-test.cpp"
    Write-Host
} else {
    # spawning too much in one go
    Write-Error "Spawn limit is 1000"
}
