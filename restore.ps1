Copy-Item -Path '.\Copy of bcc-test.cbproj' -Destination '.\bcc-test.cbproj' -Force
Copy-Item -Path '.\Copy of bcc-test.cpp' -Destination '.\bcc-test.cpp' -Force

for ($i = 1; $i -lt 1000; $i++) {
    $no = ("000" + $i)
    $no = $no.Substring($no.Length - 3, 3)
    $file = "Unit?" + $no + ".*"
    Remove-Item $file -Force
}
Remove-Item "*.cpp-*" -Force
Remove-Item "*.csv" -Force