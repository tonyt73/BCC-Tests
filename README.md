# BCC-Tests
 Test the performce of the BCC compilers in RAD Studio

1. Open a PowerShell prompt in the repository check out folder
2. Run `.\spawn.ps1 <number>`
   - This will spawn `<number>` additional files
   - You can keep spawning new files to test the effects of more files on the compilers
   - e.g:
       - `.\spawn.ps1 10` with make files `01..10`
       - `.\spawn.ps1 10` with make files `11..20`
       - `.\spawn.ps1 50` with make files `21..70` etc
3. Open the project `bcc-test.cbproj` in RAD Studio
4. Build each Platform target (Shift+F9)
   - Take note of the build times
   - Over 200 files and you should notice that the bcc64x (modern) compile is now slower than the older compilers
5. Run `.\restore.ps1` to restore the test project to its original state

