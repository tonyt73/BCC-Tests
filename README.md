# BCC-Tests
 Test the performce of the BCC compilers in RAD Studio

1. Open a PowerShell prompt in the repository check out folder
2. Run .\spawn.ps1 <number> 
   - This will spawn <number> additional files
3. Open the project bcc-test.cbproj in RAD Studio
4. Build each Platform target
   - Take note of the build times
   - Over 200 files and you should notice that the bcc64x (modern) compile is now slower than the older compilers
   
