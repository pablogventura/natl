# natl — Natural Language to Linux

Herramienta de consola que traduce instrucciones en lenguaje natural a **un comando de shell** usando un LLM local (Ollama). El comando se **inserta en la línea del prompt** sin ejecutarse; puedes editarlo o pulsar Enter para ejecutarlo.

## Requisitos

- **Bash** (o Zsh)
- **Ollama** en ejecución con al menos un modelo (p. ej. `llama3.2`)
- **curl**, **jq**

## Instalación

### Con el script de instalación (recomendado)

Desde el directorio del proyecto:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

Opciones de `install.sh`:
- **`--bash`** — Integración solo en `~/.bashrc`
- **`--zsh`** — Integración solo en `~/.zshrc`
- **`--all`** — En ambos (por defecto)
- **`--no-shell`** — Solo instalar el binario en `~/bin`, sin tocar la configuración del shell

Luego ejecuta `source ~/.bashrc` o `source ~/.zshrc`.

### Desinstalación

```bash
./uninstall.sh
```

Quita `~/bin/natl` y elimina el bloque de integración de `.bashrc` y `.zshrc`. Con `--no-shell` solo se elimina el binario.

### Instalación manual

1. Haz ejecutable el script: `chmod +x natl`
2. Enlaza en tu PATH: `ln -s /ruta/a/natl/natl ~/bin/natl`
3. Añade a `~/.bashrc` o `~/.zshrc`:
   ```bash
   export NATL_BIN=~/bin/natl
   source /ruta/a/natl/shell/bash_integration.sh   # o zsh_integration.sh
   ```

## Uso

### En el prompt (recomendado)

1. Escribe en lenguaje natural, con o sin la palabra `natl`:
   - `natl listar todos los archivos incluyendo ocultos`
   - `listar todos los archivos incluyendo ocultos`

2. Pulsa **Ctrl+G**. La línea se sustituye por el comando, por ejemplo:
   - `ls -a`

3. Edita si quieres y pulsa **Enter** para ejecutar.

### Como comando

Si ejecutas `natl` como comando (sin la integración en la línea), imprime el comando en la salida estándar:

```bash
$ natl buscar todos los archivos pdf
find . -name "*.pdf"
```

## Opciones del script

- **`-m, --model MODELO`** — Modelo de Ollama (por defecto: `llama3.2`).
- **`-e, --explain`** — Pedir al modelo una breve explicación (útil para depuración).
- **`-h, --help`** — Ayuda.

Variables de entorno:

- **`NATL_BIN`** — Ruta al script `natl` (usado por las integraciones).
- **`NATL_DIR`** — Directorio del proyecto (para localizar `prompt.txt`).
- **`NATL_MODEL`** — Modelo por defecto.
- **`OLLAMA_URL`** — URL de Ollama (por defecto: `http://localhost:11434`).

## Seguridad

El script rechaza comandos que coinciden con patrones considerados peligrosos (p. ej. `rm -rf /`, `mkfs`, `dd` sobre dispositivos, fork bombs). La lista está en el script; puedes revisarla y ampliarla.

## Estructura del proyecto

```
natl/
├── natl              # Script principal
├── install.sh        # Instalación en ~/bin e integración shell
├── uninstall.sh      # Desinstalación
├── README.md
├── prompt.txt        # Plantilla del prompt al LLM
└── shell/
    ├── bash_integration.sh
    └── zsh_integration.sh
```

## Ejemplos

| Entrada (lenguaje natural)        | Comando generado                    |
|-----------------------------------|-------------------------------------|
| listar todos los archivos ocultos | `ls -a`                             |
| buscar todos los archivos pdf     | `find . -name "*.pdf"`              |
| procesos que más memoria usan     | `ps aux --sort=-%mem \| head`       |
| contar líneas en archivos python  | `wc -l *.py`                        |

## Criterios de éxito

- Traduce lenguaje natural a comandos útiles.
- Inserta el comando en el prompt (con Ctrl+G) sin ejecutarlo.
- No ejecuta automáticamente.
- Rápido con modelo local (objetivo &lt;1 s según modelo y hardware).
