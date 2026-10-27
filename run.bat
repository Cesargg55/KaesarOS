@echo off
rem Compila y arranca KaesarOS en QEMU
call build.bat
if errorlevel 1 exit /b 1
qemu-system-x86_64 -drive format=raw,file=build\kaesaros.img
