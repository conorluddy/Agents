# Agents

General sharing repo for prompts/agents/useful agent related stuff. 

# Claude Code Agents

A repository for managing specialized Claude Code agent configurations that extend Claude's capabilities for specific development workflows.

## What are Claude Code Agents?

Claude Code agents are specialized configurations that customize Claude's behavior for specific development scenarios. Each agent includes:

- **Custom system prompts** tailored for specific tasks
- **Model specifications** (e.g., Opus for complex reasoning)
- **Usage examples** and context patterns
- **UI customization** (colors, descriptions)

## Available Agents

### 🧠 Feature Brainstormer
Strategic product evolution and lateral thinking for identifying feature opportunities within existing codebases.

### 📊 Repo Analyzer  
Comprehensive codebase analysis and documentation, perfect for understanding unfamiliar repositories or updating project documentation.

### 📱 Swift Issue Resolver
iOS/Swift development specialist that takes full ownership of GitHub issues, from analysis through PR creation.

## Quick Start

### Sync Your Agents
```bash
./sync-agents.sh
```

This script automatically:
- Copies agent files from `~/.claude/agents/` 
- Commits changes to the repository
- Pushes updates to GitHub

### Manual Setup
If you need to make the script executable:
```bash
chmod +x sync-agents.sh
```

## Agent Development

Want to create a new agent? Follow the standard format:

```yaml
---
name: your-agent-name
description: Clear description with usage examples
model: opus
color: red|purple|green
---

Your custom system prompt goes here...
```

Edit files in your local `~/.claude/agents/` directory, then sync with the script.

## Repository Structure

```
agents/
├── feature-brainstormer.md    # Strategic feature ideation
├── repo-analyzer.md           # Codebase analysis
└── swift-issue-resolver.md    # iOS development

sync-agents.sh                 # Automated sync script
```

## About

This repository syncs agent configurations between your local Claude Code setup and GitHub, ensuring your custom agents are versioned and shareable across development environments.
