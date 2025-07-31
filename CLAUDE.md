# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository manages Claude Code agent configuration files that extend Claude's capabilities for specific development scenarios. It serves as a centralized sync point between local agent configurations (`~/.claude/agents/`) and a versioned GitHub repository.

## Key Commands

### Sync Agent Files
```bash
./sync-agents.sh
```
Copies all agent files from `~/.claude/agents/` to the `agents/` directory, commits changes, and pushes directly to main branch.

### Make Script Executable (if needed)
```bash
chmod +x sync-agents.sh
```

## Repository Structure

- **`agents/`** - Agent definition files (`.md` format with YAML frontmatter)
- **`sync-agents.sh`** - Automated syncing script
- **`README.md`** - Basic repository documentation

## Agent Configuration Format

Each agent file follows this structure:

```yaml
---
name: agent-name
description: Detailed description with usage examples
model: opus
color: red|purple|green
---

System prompt content in Markdown format...
```

## Current Agents

- **feature-brainstormer** - Strategic feature ideation and product evolution
- **repo-analyzer** - Comprehensive codebase analysis and documentation  
- **swift-issue-resolver** - iOS/Swift development with GitHub issue management

## Development Workflow

1. Edit agent files locally in `~/.claude/agents/`
2. Run `./sync-agents.sh` to sync changes to repository
3. Script handles git operations automatically (add, commit, push to main)

## Important Notes

- **Git Flow Override**: This repository pushes directly to main branch for simplicity, overriding the standard git-flow practices used elsewhere
- **Source of Truth**: Local `~/.claude/agents/` directory is the primary location for editing
- **Automation**: All git operations are handled by the sync script to maintain consistency
- **File Permissions**: Sync script should remain executable

## Agent Development Guidelines

- Use kebab-case for agent names
- Include comprehensive usage examples in descriptions
- Specify appropriate model (opus for complex reasoning)
- Choose descriptive UI colors
- Write clear, focused system prompts
- Test agent functionality before syncing