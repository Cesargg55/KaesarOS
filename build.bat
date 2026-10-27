@echo off
rem Compila KaesarOS: src\boot.asm -> build\kaesaros.img
if not exist build mkdir build
nasm -f bin src\boot.asm -o build\kaesaros.img
if errorlevel 1 exit /b 1
echo Compilado: build\kaesaros.img
