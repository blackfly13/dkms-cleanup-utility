# 🔧 DKMS Cleanup Utility

[![Shell](https://img.shields.io/badge/language-bash-blue.svg)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Build](https://img.shields.io/badge/type-utility-lightgrey.svg)](https://github.com/)

A simple yet powerful script to **clean up broken or stale DKMS module builds** on Linux systems.

---

## 📦 Features

- 🧹 Removes broken DKMS module entries
- 🕵️ Detects builds for uninstalled kernels
- 🔎 Dry run mode to preview deletions
- 📜 Optional logging to file
- 👤 Interactive prompt before deletion

---

## 🖥️ Usage

```bash
chmod +x dkms-cleanup.sh

# Basic scan and cleanup
./dkms-cleanup.sh

# Preview what would be deleted
./dkms-cleanup.sh --dry-run

# Ask before each removal
./dkms-cleanup.sh --interactive

# Save output to a file
./dkms-cleanup.sh --log ~/dkms-cleanup.log

# Combine options
./dkms-cleanup.sh --dry-run --log cleanup.log

```

### Options

| Flag            | Description                               |
|-----------------|-------------------------------------------|
| `--dry-run`     | Show what would be removed without deleting |
| `--interactive` | Ask before deleting each entry            |
| `--log <file>`  | Log actions and output to a file          |
| `--help`        | Show usage info                           |

---

## 🛡️ Requirements

- Linux system with DKMS
- Bash
- sudo privileges

---

## 🪪 License

MIT License - see [LICENSE](LICENSE)
