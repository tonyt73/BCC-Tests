@call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
msbuild "bcc-test.cbproj" /t:clean /p:config="Release" /p:platform=Win32
msbuild "bcc-test.cbproj" /t:build /p:config="Release" /p:platform=Win32
