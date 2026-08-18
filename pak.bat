@echo off
setlocal enabledelayedexpansion

set "UE_ROOT=C:\Program Files\Epic Games\UE_5.2"
set "REPAK=repak"
set "RETOC=retoc"
set "PAK_VERSION=V11"
set "ZEN_VERSION=UE5_2"
set "MOD_NAME=ModMenu"

set "PROJ_DIR=C:\Users\x\Documents\Unreal Projects\Stonemachia"
set "PROJ=%PROJ_DIR%\Stonemachia.uproject"
set "GAME_PAKS=x\Stonemachia\Stonemachia\Content\Paks\LogicMods"
set "STAGE=%PROJ_DIR%\Saved\ModStage"
set "STAGE_ROOT=%STAGE%\pak"
set "LEGACY=%STAGE%\%MOD_NAME%_legacy.pak"
set "ZENOUT=%STAGE%\zen"
set "EDITOR=%UE_ROOT%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
set "COOKED=%PROJ_DIR%\Saved\Cooked\Windows\Stonemachia\Content\Mods"

if not exist "%PROJ%" (echo [^!] uproject not found: %PROJ% & exit /b 1)
if not exist "%EDITOR%" (echo [^!] editor not found: %EDITOR% & exit /b 1)

if /i "%REPAK%"=="repak" (
  where repak >nul 2>&1 || (echo [^!] repak not on PATH & exit /b 1)
) else (
  if not exist "%REPAK%" (echo [^!] repak not found: %REPAK% & exit /b 1)
)
if /i "%RETOC%"=="retoc" (
  where retoc >nul 2>&1 || (echo [^!] retoc not on PATH & exit /b 1)
) else (
  if not exist "%RETOC%" (echo [^!] retoc not found: %RETOC% & exit /b 1)
)

if exist "%PROJ_DIR%\Saved\Cooked" rmdir /s /q "%PROJ_DIR%\Saved\Cooked"

"%EDITOR%" "%PROJ%" -run=Cook -targetplatform=Windows -nodebuginfo -stdout
if errorlevel 1 (echo [^!] cook failed & exit /b 1)
if not exist "%COOKED%\%MOD_NAME%\ModActor.uasset" (
  echo [^!] cook produced no ModActor at %COOKED%\%MOD_NAME%
  exit /b 1
)

if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE_ROOT%\Stonemachia\Content\Mods"

robocopy "%COOKED%" "%STAGE_ROOT%\Stonemachia\Content\Mods" /E /NFL /NDL /NJH /NJS /NP ^
  /XF "*.uexp.tmp" "*.ushaderbytecode" "*.assetinfo.json"
if errorlevel 8 (echo [^!] robocopy failed & exit /b 1)

dir /b /s /a-d "%STAGE_ROOT%" | findstr /v /i /c:"Content\Mods\%MOD_NAME%" > "%STAGE%\stray.txt"
for %%A in ("%STAGE%\stray.txt") do if not %%~zA==0 (
  echo [x] files outside mod folder:
  type "%STAGE%\stray.txt"
  exit /b 1
)

if exist "%LEGACY%" del "%LEGACY%"
"%REPAK%" pack --version %PAK_VERSION% "%STAGE_ROOT%" "%LEGACY%"
if errorlevel 1 (echo [^!] repak failed & exit /b 1)

if exist "%ZENOUT%" rmdir /s /q "%ZENOUT%"
mkdir "%ZENOUT%"
"%RETOC%" to-zen --version %ZEN_VERSION% "%LEGACY%" "%ZENOUT%\%MOD_NAME%.utoc"
if errorlevel 1 (echo [^!] retoc failed & exit /b 1)
if not exist "%ZENOUT%\%MOD_NAME%.utoc" (echo [^!] retoc produced no utoc & exit /b 1)

if not exist "%GAME_PAKS%" mkdir "%GAME_PAKS%"
del /q "%GAME_PAKS%\%MOD_NAME%.pak" "%GAME_PAKS%\%MOD_NAME%.utoc" "%GAME_PAKS%\%MOD_NAME%.ucas" 2>nul
copy /y "%ZENOUT%\%MOD_NAME%.*" "%GAME_PAKS%\" >nul
if errorlevel 1 (echo [^!] copy failed - is the game running? & exit /b 1)

dir /b "%GAME_PAKS%\%MOD_NAME%.*"