#!/bin/bash

set -euo pipefail

# =========================
# Configuration
# =========================

GITLAB_URL="https://192.168.X.X/usa/OV_List.git"
GITLAB_USERNAME="usa"
GITLAB_TOKEN="XXXX"

LOCAL_PATH="/root/hani"
BRANCH="master"

COMMIT_MESSAGE="Automated update - $(date '+%Y-%m-%d %H:%M:%S')"

# =========================
# Colors
# =========================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting GitLab push...${NC}"

# =========================
# Configure credentials
# =========================

git config --global credential.helper store

cat > ~/.git-credentials << EOF
https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@192.168.X.X
EOF

chmod 600 ~/.git-credentials

# =========================
# Go to project directory
# =========================

cd "$LOCAL_PATH"

# =========================
# Initialize repository
# =========================

if [ ! -d ".git" ]; then
echo -e "${GREEN}Initializing Git repository...${NC}"
git init
fi

# =========================
# Git identity
# =========================

git config user.name "Automation User"
git config user.email "automation@local"

# =========================
# Configure remote
# =========================

if git remote get-url origin >/dev/null 2>&1; then
git remote set-url origin "$GITLAB_URL"
else
git remote add origin "$GITLAB_URL"
fi

# =========================
# Add files
# =========================

echo -e "${GREEN}Adding files...${NC}"
git add --all

# =========================
# Commit only if needed
# =========================

if git diff --cached --quiet; then
echo -e "${YELLOW}No changes detected.${NC}"
else
echo -e "${GREEN}Creating commit...${NC}"
git commit -m "$COMMIT_MESSAGE"
fi

# =========================
# Push
# =========================

echo -e "${GREEN}Pushing to GitLab...${NC}"
git push -u origin "$BRANCH" --force

echo -e "${GREEN}SUCCESS: Repository updated.${NC}"

