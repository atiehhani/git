#!/bin/bash

# Automated script to force push local files to GitLab
# WARNING: This will REPLACE everything on GitLab with local files!

# Configuration
GITLAB_URL="https://192.168.X.X/usa/OV_List.git"
GITLAB_USERNAME="usa"
GITLAB_PASSWORD="your-password-here"  # Add your password here
LOCAL_PATH="/lotus"
BRANCH="master"
COMMIT_MESSAGE="Force replace - $(date '+%Y-%m-%d %H:%M:%S')"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting automated force push to GitLab...${NC}"

# Navigate to local directory
cd $LOCAL_PATH || { echo -e "${RED}Error: Cannot access $LOCAL_PATH${NC}"; exit 1; }

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo -e "${GREEN}Initializing git repository...${NC}"
    git init
fi

# Add/update remote with username in URL
if git remote | grep -q "origin"; then
    git remote set-url origin https://${GITLAB_USERNAME}@192.168.X.X/usa/OV_List.git
else
    git remote add origin https://${GITLAB_USERNAME}@192.168.X.X/usa/OV_List.git
fi

# Add all files
echo -e "${GREEN}Adding all files...${NC}"
git add --all

# Commit changes
echo -e "${GREEN}Committing files...${NC}"
git commit -m "$COMMIT_MESSAGE"

# Force push to GitLab with credentials
echo -e "${GREEN}Force pushing to GitLab...${NC}"
git push -u origin $BRANCH --force https://${GITLAB_USERNAME}:${GITLAB_PASSWORD}@192.168.X.X/usa/OV_List.git

# Check result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS! Local files replaced GitLab repository.${NC}"
else
    echo -e "${RED}FAILED! Push was rejected.${NC}"
    exit 1
fi
