@echo off
SetLocal EnableExtensions

if exist ..\..\addons\sourcemod\data (
  set list=..\..\addons\sourcemod\data\music_mapstart.txt
) else (
  set list=music_mapstart.txt
)

2> NUL del "%list%"
for %%a in ("%~p0") do set "p=%%~a"
set "p=%p:~0,-1%"
for /f %%a in ("%p%") do set "p=%%~nxa"
for %%a in (*.mp3) do >> "%list%" < NUL set /p "=%p%" & >> "%list%" echo /%%a

echo File list is successfully saved to: %list%
echo.
pause

goto :eof