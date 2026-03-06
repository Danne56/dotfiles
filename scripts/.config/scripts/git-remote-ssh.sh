#!/bin/bash

# Get the current remote URL (origin)
CURRENT_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$CURRENT_URL" ]; then
  echo "Error: no remote named 'origin' found in this directory."
  exit 1
fi

# Check if it's already an SSH URL
if [[ $CURRENT_URL == git@* ]]; then
  echo "Remote is already using SSH: $CURRENT_URL"
  exit 0
fi

# Convert HTTPS to SSH
# Works for GitHub, GitLab, and Bitbucket
if [[ $CURRENT_URL =~ ^https://([^/]+)/(.+)$ ]]; then
  DOMAIN=${BASH_REMATCH[1]}
  REPO=${BASH_REMATCH[2]}

  # Remove .git suffix if present to avoid doubling it
  REPO=${REPO%.git}

  NEW_URL="git@$DOMAIN:$REPO.git"

  echo "Converting HTTPS to SSH..."
  echo "From: $CURRENT_URL"
  echo "To:   $NEW_URL"

  git remote set-url origin "$NEW_URL"
  echo "Done. Remote updated to SSH."
else
  echo "Error: remote URL is not a standard HTTPS URL."
  exit 1
fi
