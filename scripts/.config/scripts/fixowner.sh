#!/usr/bin/env bash
set -e

# Fix directory permissions to 755 (drwxr-xr-x)
find . -type d -exec sudo chown -R ${whoami}:${whoami} {} +

# Fix file permissions to 644 (-rw-r--r--)
find . -type f -exec sudo chown -R ${whoami}:${whoami} {} +
