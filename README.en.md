# natl — Natural Language to Linux

A console tool that turns **natural language** into a **single Linux shell command** using a local LLM (Ollama). The command is **inserted into your prompt** without being run; you can edit it or press Enter to execute.

## Requirements

- **Bash** (or Zsh)
- **Ollama** running with at least one model (e.g. `llama3.2`)
- **curl**, **jq**

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

## Usage

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

- **`-m, --model MODEL`** — Ollama model (default: `llama3.2`).
- **`-e, --explain`** — Ask the model for a short explanation (debugging).
- **`-h, --help`** — Show help.

Environment variables:

- **`NATL_BIN`** — Path to the `natl` script (used by shell integrations).
- **`NATL_DIR`** — Project directory (to find `prompt.txt`).
- **`NATL_MODEL`** — Default model.
- **`OLLAMA_URL`** — Ollama API URL (default: `http://localhost:11434`).

## Security

The script blocks commands that match dangerous patterns (e.g. `rm -rf /`, `mkfs`, `dd` to devices, fork bombs). The list is in the script; you can review and extend it.

## Project layout

```
natl/
├── natl              # Main script
├── install.sh        # Install to ~/bin and add shell integration
├── uninstall.sh      # Uninstall
├── README.md
├── README.en.md      # This file
├── prompt.txt        # LLM prompt template
└── shell/
    ├── bash_integration.sh
    └── zsh_integration.sh
```

## Examples

| Natural language input        | Generated command              |
|------------------------------|--------------------------------|
| list all files including hidden | `ls -a`                     |
| find all pdf files            | `find . -name "*.pdf"`         |
| processes using most memory   | `ps aux --sort=-%mem \| head`  |
| count lines in python files   | `wc -l *.py`                   |

## Success criteria

- Translates natural language into useful commands.
- Inserts the command into the prompt (via Ctrl+G) without executing it.
- Does not run commands automatically.
- Fast with a local model (target &lt;1 s depending on model and hardware).
