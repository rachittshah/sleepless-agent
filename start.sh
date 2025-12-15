#!/bin/bash

# Sleepless Agent Startup Script
# This script activates the virtual environment and starts the sleepless agent daemon

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            Sleepless Agent Startup                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please create a .env file with your Slack tokens.${NC}"
    echo -e "You can copy .env.example as a template:"
    echo -e "  ${GREEN}cp .env.example .env${NC}"
    echo -e "Then edit .env and add your Slack tokens from https://api.slack.com/apps"
    exit 1
fi

# Check if SLACK_BOT_TOKEN and SLACK_APP_TOKEN are set
source .env
if [[ "$SLACK_BOT_TOKEN" == "xoxb-your-slack-bot-token-here" ]] || [[ "$SLACK_APP_TOKEN" == "xapp-your-slack-app-token-here" ]]; then
    echo -e "${RED}Error: Slack tokens not configured!${NC}"
    echo -e "${YELLOW}Please edit the .env file and add your Slack tokens.${NC}"
    echo -e "Get your tokens from: ${BLUE}https://api.slack.com/apps${NC}"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${RED}Error: Virtual environment not found!${NC}"
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"

    echo -e "${YELLOW}Installing dependencies...${NC}"
    source venv/bin/activate
    uv pip install -e .
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Virtual environment found${NC}"
    source venv/bin/activate
fi

# Check if Claude Code CLI is installed
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code CLI not found!${NC}"
    echo -e "${YELLOW}Please install Claude Code CLI:${NC}"
    echo -e "  ${GREEN}npm install -g @anthropic-ai/claude-code${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Claude Code CLI found${NC}"

# Display configuration
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  Active hours: ${GREEN}10 PM - 7 AM${NC}"
echo -e "  Model: ${GREEN}Claude Sonnet 4.5${NC}"
echo -e "  Fallback: ${GREEN}Claude Opus 4.5${NC}"
echo -e "  Max thinking tokens: ${GREEN}31,999${NC}"
echo -e "  Workspace: ${GREEN}./workspace${NC}"
echo ""

# Start the daemon
echo -e "${BLUE}Starting Sleepless Agent daemon...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Run the daemon
sle daemon
