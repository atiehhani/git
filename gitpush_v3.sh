#!/bin/bash

# Configuration
GITLAB_URL="https://192.168.243.9/usa/OV_List.git"
GITLAB_USERNAME="usa"
#GITLAB_PASSWORD='E$DmAp@uLCP_1404'  # Use single quotes to avoid $ expansion
GITLAB_TOKEN="glpat-WS3MdXTp6fBzbGLTkVRsJG86MQp1OjEH.01.0w1mia0g4"
LOCAL_PATH="/root/lotus"
BRANCH="master"
COMMIT_MESSAGE="Force replace - $(date '+%Y-%m-%d %H:%M:%S')"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting automated force push to GitLab...${NC}"

# Clear existing credentials to avoid conflicts
git config --global --unset credential.helper
git config --global credential.helper store

# Use the FULL URL (without the protocol part in the file)
echo "https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@192.168.243.9" > ~/.git-credentials

# Navigate to local directory
cd $LOCAL_PATH || { echo -e "${RED}Error: Cannot access $LOCAL_PATH${NC}"; exit 1; }

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo -e "${GREEN}Initializing git repository...${NC}"
    git init
fi

# Set user identity (required for commit)
git config user.email "usa@local.local"
git config user.name "USA User"

# Add/update remote
if git remote | grep -q "origin"; then
    git remote set-url origin $GITLAB_URL
else
    git remote add origin $GITLAB_URL
fi

# Add all files
echo -e "${GREEN}Adding all files...${NC}"
git add --all

# Commit changes
echo -e "${GREEN}Committing files...${NC}"
git commit -m "$COMMIT_MESSAGE"

# Force push - embed credentials in URL as fallback
echo -e "${GREEN}Force pushing to GitLab...${NC}"
git push -u origin $BRANCH --force

# Check result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}SUCCESS! Local files replaced GitLab repository.${NC}"
else
    echo -e "${RED}FAILED! Push was rejected.${NC}"
    echo -e "${YELLOW}Alternative: Try pushing with embedded credentials...${NC}"
    
    # Alternative method - embed credentials directly in URL
    git push -u "https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@192.168.243.9/usa/OV_List.git" $BRANCH --force
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SUCCESS with embedded credentials!${NC}"
    else
        echo -e "${RED}Still failing. Check if:${NC}"
        echo "1. GitLab server is accessible: curl -k https://192.168.243.9"
        echo "2. Username/password is correct"
        echo "3. You have push permissions"
        exit 1
    fi
fi
