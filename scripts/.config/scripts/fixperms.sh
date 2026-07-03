#!/usr/bin/env bash
set -e

# Fix directory permissions to 755 (drwxr-xr-x)
find . -type d -exec chmod 755 {} +

# Fix file permissions to 644 (-rw-r--r--)
find . -type f -exec chmod 644 {} +
