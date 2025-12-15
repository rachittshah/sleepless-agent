# Sleepless Agent - Local Setup Guide

Your sleepless agent is configured and ready to run from **10 PM to 7 AM** using **Claude Sonnet 4.5** (with Opus 4.5 fallback) and **31,999 thinking tokens** for extended reasoning.

## Quick Start

```bash
cd ~/sleepless-agent
./start.sh
```

That's it! The script will check everything and start the daemon.

---

## Slack Setup Steps

Before running the agent, you need to create a Slack app and get your tokens.

### Step 1: Create Slack App

1. Go to https://api.slack.com/apps
2. Click **"Create New App"**
3. Select **"From scratch"**
4. App Name: `Sleepless Agent`
5. Pick your workspace
6. Click **"Create App"**

### Step 2: Enable Socket Mode

1. In your app settings, go to **Settings → Socket Mode**
2. Toggle **"Enable Socket Mode"** to **ON**
3. When prompted, create an app-level token:
   - Token Name: `sleepless-token`
   - Scope: `connections:write`
   - Click **"Generate"**
4. **IMPORTANT**: Copy the token that starts with `xapp-` and save it!

### Step 3: Add Bot Scopes

1. Go to **Features → OAuth & Permissions**
2. Scroll to **Bot Token Scopes**
3. Add these scopes:
   - `chat:write` - Send messages
   - `chat:write.public` - Send to public channels
   - `commands` - Receive slash commands
   - `app_mentions:read` - Respond to @mentions
   - `channels:read` - List channels
   - `groups:read` - Access private channels
   - `im:read` - Read DMs
   - `im:write` - Send DMs
   - `users:read` - Get user info

### Step 4: Create Slash Commands

Go to **Features → Slash Commands** and create these commands:

#### /think
- Command: `/think`
- Short Description: `Submit a task or thought`
- Usage Hint: `[description] [-p project_name]`

#### /check
- Command: `/check`
- Short Description: `Check system status and queue`
- Usage Hint: `[no arguments]`

#### /report
- Command: `/report`
- Short Description: `View task reports`
- Usage Hint: `[task_id | date | project_name | --list]`

#### /cancel
- Command: `/cancel`
- Short Description: `Cancel a task or project`
- Usage Hint: `<task_id | project_name>`

#### /trash
- Command: `/trash`
- Short Description: `Manage cancelled tasks`
- Usage Hint: `<list | restore <id> | empty>`

**Note**: For all commands, leave "Request URL" empty since we're using Socket Mode.

### Step 5: Install App to Workspace

1. Go to **Settings → Install App**
2. Click **"Install to Workspace"**
3. Review permissions and click **"Allow"**
4. **IMPORTANT**: Copy the **Bot User OAuth Token** (starts with `xoxb-`)

### Step 6: Configure Tokens

Edit `~/sleepless-agent/.env` and add your tokens:

```bash
# Replace with your actual tokens from Slack
SLACK_BOT_TOKEN=xoxb-your-bot-token-here
SLACK_APP_TOKEN=xapp-your-app-token-here
```

### Step 7: Invite Bot to Channels

In any Slack channel where you want to use the bot:

```
/invite @sleepless-agent
```

---

## Configuration Details

The agent is configured with:

- **Active Hours**: 10 PM - 7 AM (night_start_hour: 22, night_end_hour: 7)
- **Primary Model**: Claude Sonnet 4.5 (`claude-sonnet-4-5-20250929`)
- **Fallback Model**: Claude Opus 4.5 (`claude-opus-4-5-20251101`)
- **Max Thinking Tokens**: 31,999 (for extended reasoning)
- **Day Threshold**: 20% usage
- **Night Threshold**: 80% usage

Configuration file: `~/sleepless-agent/src/sleepless_agent/config.yaml`

---

## Using the Agent

### Submit Tasks via Slack

**Quick thought** (auto-processed during off-hours):
```
/think Explore async patterns in Python
```

**Project task** (requires manual review):
```
/think Add OAuth support -p backend
```

### Check Status
```
/check
```

### View Reports
```
/report
/report 42
/report --list
```

### Cancel Tasks
```
/cancel 42
/cancel backend
```

---

## File Structure

```
~/sleepless-agent/
├── start.sh              # Easy startup script
├── .env                  # Your Slack tokens (DO NOT COMMIT)
├── workspace/            # Agent workspace (created automatically)
│   ├── tasks/           # Individual task workspaces
│   ├── projects/        # Project-based workspaces
│   ├── shared/          # Shared resources
│   └── data/            # Database and results
├── src/
│   └── sleepless_agent/
│       └── config.yaml  # Configuration file
└── venv/                # Python virtual environment
```

---

## Troubleshooting

### Bot not responding in Slack

1. Check that the daemon is running: `ps aux | grep sle`
2. Check tokens are correct in `.env`
3. Verify Socket Mode is enabled in Slack app settings
4. Check logs for errors

### "Claude Code CLI not found"

Install Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

### Agent not running during configured hours

The agent runs from **10 PM to 7 AM**. Outside these hours, it will pause to respect the configured thresholds.

### Check Agent Status

```bash
cd ~/sleepless-agent
source venv/bin/activate
sle check
```

---

## Advanced Configuration

### Change Active Hours

Edit `~/sleepless-agent/src/sleepless_agent/config.yaml`:

```yaml
claude_code:
  night_start_hour: 22  # 10 PM
  night_end_hour: 7     # 7 AM
```

### Change Models

```yaml
claude_code:
  model: claude-sonnet-4-5-20250929
  fallback_model: claude-opus-4-5-20251101
  max_thinking_tokens: 31999
```

### Add Git Remote (Optional)

```yaml
git:
  use_remote_repo: true
  remote_repo_url: git@github.com:yourusername/your-repo.git
  auto_create_repo: true
```

---

## Stopping the Agent

Press `Ctrl+C` in the terminal where the agent is running, or:

```bash
pkill -f "sle daemon"
```

---

## Support

- **Documentation**: See `docs/` folder
- **Slack Setup Guide**: `docs/guides/slack-setup.md`
- **GitHub**: https://github.com/context-machine-lab/sleepless-agent

---

## Security Notes

- Never commit `.env` file to git (already in .gitignore)
- Keep your Slack tokens secret
- Rotate tokens periodically from https://api.slack.com/apps
