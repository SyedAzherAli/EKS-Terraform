#!//bin/bash
if command -v apt-get &> /dev/null; then sudo apt-get update && sudo apt-get upgrade -y; elif command -v dnf &> /dev/null; then sudo dnf update -y; else echo "Unknown package manager"; fi
