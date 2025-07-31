#!/bin/bash

# Script to sync agent files from ~/.claude/agents to this directory and push to GitHub
# Following git-flow practices with branches and PRs

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Starting agent files sync...${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check if ~/.claude/agents exists
if [ ! -d "$HOME/.claude/agents" ]; then
    echo -e "${RED}❌ Error: ~/.claude/agents directory not found${NC}"
    exit 1
fi

# Check if we have any commits yet
if git rev-parse --verify HEAD > /dev/null 2>&1; then
    # Repository has commits, ensure we're on main branch
    echo -e "${YELLOW}📥 Ensuring we're on main branch...${NC}"
    git checkout main
    
    # Check if origin remote exists and pull if it does
    if git remote get-url origin > /dev/null 2>&1; then
        # Check if main branch exists on remote
        if git ls-remote --heads origin main | grep -q main; then
            echo -e "${YELLOW}📥 Pulling latest changes from origin...${NC}"
            git pull origin main
        else
            echo -e "${YELLOW}⚠️  Remote exists but no main branch found - will push main branch later${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No origin remote found - working with local repository only${NC}"
    fi
else
    # This is a new repository with no commits
    echo -e "${YELLOW}📝 New repository detected - will create initial commit${NC}"
    # Create a simple README first
    echo "# Agents" > README.md
    echo "" >> README.md
    echo "This repository contains Claude agent configuration files." >> README.md
    git add README.md
    git commit -m "Initial commit: Add README"
fi

# Create agents directory if it doesn't exist
mkdir -p agents

# Copy all agent files from ~/.claude/agents
echo -e "${YELLOW}📋 Copying agent files...${NC}"
cp -v "$HOME/.claude/agents"/* agents/

# Add files to staging area to check for changes
git add agents/

# Check if there are any changes to commit
if git diff --cached --quiet; then
    echo -e "${GREEN}✅ No changes detected - agents are already up to date${NC}"
    exit 0
fi

# Create commit with descriptive message
AGENT_COUNT=$(ls -1 "$HOME/.claude/agents" | wc -l | tr -d ' ')
echo -e "${YELLOW}📝 Creating commit...${NC}"
git commit -m "Sync $AGENT_COUNT agent files from ~/.claude/agents

- Automated sync of agent configuration files
- Ensures repository has latest agent definitions

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push directly to main
echo -e "${YELLOW}🚀 Pushing to main...${NC}"
git push origin main

echo -e "${GREEN}🎉 Done! Agent files synced and pushed to main branch.${NC}"