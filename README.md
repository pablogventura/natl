# natl — Natural Language to Linux

A console tool that turns **natural language** into a **single Linux shell command** using a local LLM (Ollama). The command is **inserted into your prompt** without being run; you can edit it or press Enter to execute.

## Requirements

- **Python 3** (standard library only, no pip)
- **Bash** or **Zsh** (for prompt integration)
- **Ollama** running with at least one model (e.g. `llama3.2`)

## Installation

### Using the install script (recommended)

From the project directory:

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

`install.sh` options:
- **`--bash`** — Add integration only to `~/.bashrc`
- **`--zsh`** — Add integration only to `~/.zshrc`
- **`--all`** — Add to both (default)
- **`--no-shell`** — Only install the binary to `~/bin`; do not modify shell config

Then run `source ~/.bashrc` or `source ~/.zshrc` (or open a new terminal).

### Uninstall

```bash
./uninstall.sh
```

Removes `~/bin/natl` and the integration block from `.bashrc` and `.zshrc`. Use `--no-shell` to only remove the binary.

### Manual installation

1. Make the script executable: `chmod +x natl`
2. Link it into your PATH: `ln -s /path/to/natl/natl ~/bin/natl`
3. Add to `~/.bashrc` or `~/.zshrc`:
   ```bash
   export NATL_BIN=~/bin/natl
   source /path/to/natl/shell/bash_integration.sh   # or zsh_integration.sh for zsh
   ```

### Building the .deb package

Install build dependencies (Debian/Ubuntu):

```bash
sudo apt install build-essential debhelper
```

From the project root:

```bash
dpkg-buildpackage -us -uc -b
```

The `.deb` will be in the parent directory. Install with:

```bash
sudo dpkg -i ../natl_0.1.0-1_all.deb
```

The package installs `/usr/bin/natl` (symlink to `/usr/share/natl/natl`), prompt and shell integration under `/usr/share/natl/`. After install, add to your shell rc:

```bash
export NATL_BIN=/usr/bin/natl
source /usr/share/natl/shell/bash_integration.sh   # or zsh_integration.sh
```

## Usage

### Configuration menu

Running **`natl`** with no arguments opens an interactive configuration menu:

- **Ollama model** — Default model (e.g. `llama3.2`, `phi3`)
- **Ollama URL** — API base URL (default `http://localhost:11434`)
- **Extra prompt instructions** — Text appended to the prompt (e.g. “Prefer short commands”)
- **Explanation by default** — Toggle whether the model adds a brief explanation
- **List available models** — Show models reported by your Ollama instance
- **View full config** — Show current config JSON
- **Restore defaults** — Reset all options

Settings are saved to `~/.config/natl/config.json` and apply to all runs, including the Ctrl+G widget.

### In the prompt (recommended)

1. Type in natural language, with or without the word `natl`:
   - `natl list all files including hidden`
   - `list all files including hidden`

2. Press **Ctrl+G**. The line is replaced by the command, e.g.:
   - `ls -a`

3. Edit if needed and press **Enter** to run.

### As a command

If you run `natl` as a normal command, it prints the generated command to stdout:

```bash
$ natl find all pdf files
find . -name "*.pdf"
```

## Script options

- **`-m, --model MODEL`** — Ollama model (overrides config).
- **`-e, --explain`** — Ask the model for a short explanation (debugging).
- **`-h, --help`** — Show help.

Environment variables (override the config file):

- **`NATL_BIN`** — Path to the `natl` script (used by shell integrations).
- **`NATL_MODEL`** — Model to use.
- **`OLLAMA_URL`** — Ollama API URL.

## Security

The script blocks commands that match dangerous patterns (e.g. `rm -rf /`, `mkfs`, `dd` to devices, fork bombs). The list is in the script; you can review and extend it.

## Project layout

```
natl/
├── natl              # Main script (Python 3)
├── VERSION           # Single source for version (used by script and .deb build)
├── LICENSE           # MIT, (c) Pablo Ventura
├── install.sh        # Install to ~/bin and add shell integration
├── uninstall.sh      # Uninstall
├── README.md
├── prompt.txt        # LLM prompt template
├── future.md         # Future ideas (e.g. dpkg triggers)
├── debian/           # Debian package build
│   ├── control
│   ├── changelog
│   ├── rules
│   ├── compat
│   ├── copyright
│   ├── postinst
│   ├── natl.install
│   └── natl.links
└── shell/
    ├── bash_integration.sh
    └── zsh_integration.sh
```

## Examples

| Natural language input           | Generated command              |
|---------------------------------|--------------------------------|
| list all files including hidden | `ls -a`                        |
| find all pdf files              | `find . -name "*.pdf"`         |
| processes using most memory     | `ps aux --sort=-%mem \| head`  |
| count lines in python files     | `wc -l *.py`                   |

## Version

The project version is defined in a single file: **`VERSION`** (e.g. `0.1.0`). The script uses it for `natl --version`; the Debian package build reads it to set the package version. When releasing, update `VERSION` and then run `dpkg-buildpackage`; `debian/changelog` will be updated automatically at build time.

## Success criteria

- Translates natural language into useful commands.
- Inserts the command into the prompt (via Ctrl+G) without executing it.
- Does not run commands automatically.
- Fast with a local model (target &lt;1 s depending on model and hardware).
