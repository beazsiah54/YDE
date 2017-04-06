
@echo off
echo Waiting for file handle to be closed ...
ping 127.0.0.1 -n 5 -w 1000 > NUL
move /Y "C:\Users\bob\Desktop\source_YDE_v01.01.01\youtube-dl.exe.new" "C:\Users\bob\Desktop\source_YDE_v01.01.01\youtube-dl.exe" > NUL
echo Updated youtube-dl to version 2017.04.03.
start /b "" cmd /c del "%~f0"&exit /b"
                
