@echo off
setlocal
set URL=%1
set URL=%URL:telnet://=%    rem bỏ tiền tố telnet://
set URL=%URL:/=%             rem bỏ dấu /
for /f "tokens=1,2 delims=:" %%a in ("%URL%") do (
  set HOST=%%a
  set PORT=%%b
)
if "%PORT%"=="" (
  start "" "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe" -newtab telnet %HOST%
) else (
  start "" "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe" -newtab telnet %HOST% %PORT%
)
endlocal
