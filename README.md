# KaesarOS

Un sistema operativo de consola hecho desde cero, para aprender cómo funciona un ordenador por dentro.

Sin Linux, sin librerías, sin nada debajo: solo la CPU, la BIOS y código escrito a mano en ensamblador x86.

![KaesarOS arrancando en QEMU](docs/screenshot.png)

## Qué hace ahora

- Arranca desde el sector de arranque (512 bytes) con la BIOS.
- Muestra una consola (`K>`) que lee lo que escribes, con borrar y límite de 60 caracteres.
- Reconoce comandos y responde. Por ahora: `help`.


## Licencia

[MIT](LICENSE)
