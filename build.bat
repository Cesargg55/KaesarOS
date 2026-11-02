@echo off
rem Compila KaesarOS: boot + kernel -> build\kaesaros.img
if not exist build mkdir build
nasm -f bin src\boot.asm -o build\boot.bin
if errorlevel 1 exit /b 1
nasm -f bin src\kernel.asm -o build\kernel.bin
if errorlevel 1 exit /b 1
copy /b build\boot.bin+build\kernel.bin build\kaesaros.img >nul
echo Compilado: build\kaesaros.img
