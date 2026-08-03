#!/bin/bash

set -euo pipefail

GITLAB_URL="https://192.168.X.X/usa/OV_List.git"
GITLAB_USERNAME="usa"
GITLAB_TOKEN="XXXX"

LOCAL_PATH="/hani"
BRANCH="master"

COMMIT_MESSAGE="Automated update - $(date '+%Y-%m-%d %H:%M:%S')"

echo "$(date '+%F %T') - Starting GitLab push"

# Configure git credentials
git config --global credential.helper store

cat > ~/.git-credentials << EOF
https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@192.168.X.X
EOF

chmod 600 ~/.git-credentials

# Navigate to the local path
cd "$LOCAL_PATH" || { echo "ERROR: Cannot access $LOCAL_PATH"; exit 1; }

# Initialize git repository if not already present
if [ ! -d ".git" ]; then
    echo "$(date '+%F %T') - Initializing Git repository"
    git init
    git config --global user.name "Automation User"
    git config --global user.email "automation@local"
    git remote add origin "$GITLAB_URL"
else
    git config --global user.name "Automation User"
    git config --global user.email "automation@local"
    
    # Check if remote exists and update it
    if git remote get-url origin >/dev/null 2>&1; then
        git remote set-url origin "$GITLAB_URL"
    else
        git remote add origin "$GITLAB_URL"
    fi
fi

echo "$(date '+%F %T') - Adding files"
git add --all

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "$(date '+%F %T') - No changes detected"
else
    echo "$(date '+%F %T') - Creating commit"
    git commit -m "$COMMIT_MESSAGE"
fi

echo "$(date '+%F %T') - Pushing to GitLab"
git push -u origin "$BRANCH" --force

echo "$(date '+%F %T') - SUCCESS"
