@ECHO OFF
SET USERNAME="root"
SET PASSWORD="eve"

SET S=%1
SET S=%S:capture://=%
FOR /f "tokens=1,2 delims=/ " %%a IN ("%S%") DO SET HOST=%%a&SET INT=%%b
IF "%INT%" == "pnet0" SET FILTER=" not port 22"

ECHO "Connecting to %USERNAME%@%HOST%..."

"C:\Program Files\PuTTY\plink.exe" -ssh -batch -pw %PASSWORD% %USERNAME%@%HOST% "tcpdump -U -i %INT% -s 0 -w -%FILTER%" | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
