# Compila y arranca KaesarOS en Linux / macOS (en Windows: build.bat y run.bat)

IMG := build/kaesaros.img

.PHONY: all run clean

all: $(IMG)

$(IMG): src/boot.asm | build
	nasm -f bin $< -o $@

build:
	mkdir -p build

run: $(IMG)
	qemu-system-x86_64 -drive format=raw,file=$(IMG)

clean:
	rm -rf build
