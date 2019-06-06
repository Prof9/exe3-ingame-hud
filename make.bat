@echo off

mkdir "_rom" 2> nul
mkdir "_temp" 2> nul

tools\PixelPet.exe ^
	Import-Bitmap "font.pal.png" Read-Palettes Convert-Palettes GBA ^
	Import-Bitmap "font.png" Convert-Bitmap GBA ^
	Generate-Tilemap GBA-4BPP --no-reduce ^
	Serialize-Tileset Export-Bytes "_temp\font.img.bin"
if %errorlevel% neq 0 goto :error

tools\armips.exe src.asm ^
	-strequ ROM_IN "_rom\exe3-jp-v10.gba" ^
	-strequ ROM_OUT "_rom\exe3-jp-v10-patched.gba" ^
	-sym "_rom\exe3-jp-v10-patched.sym"
if %errorlevel% neq 0 goto :error

tools\armips.exe src.asm ^
	-strequ ROM_IN "_rom\bn3b-us.gba" ^
	-strequ ROM_OUT "_rom\bn3b-us-patched.gba" ^
	-sym "_rom\bn3b-us-patched.sym"
if %errorlevel% neq 0 goto :error

echo.
echo ROM built successfully
exit /b 0

:error
echo.
echo Error, ROM could not be build
pause
exit /b 1