# Fork Maintenance Guide

This repository is a fork of [context-machine-lab/sleepless-agent](https://github.com/context-machine-lab/sleepless-agent).

## Remote Configuration

```bash
origin    https://github.com/rachittshah/sleepless-agent.git
upstream  https://github.com/context-machine-lab/sleepless-agent.git
```

## Syncing with Upstream

To pull updates from the original repository:

```bash
# Fetch upstream changes
git fetch upstream

# Switch to main branch
git checkout main

# Merge upstream changes
git merge upstream/main

# Or rebase (cleaner history but rewrites commits)
# git rebase upstream/main

# Push updates to your fork
git push origin main
```

## Custom Changes in This Fork

This fork includes the following customizations for Claude Code v2.0.69 compatibility:

### 1. Claude Code v2.0.69 Usage Command Fix
- **File**: `src/sleepless_agent/monitoring/pro_plan_usage.py:62`
- **Change**: Updated default command from `"claude usage"` to `"claude /usage"`
- **Reason**: v2.0.69 changed `claude usage` to launch an interactive session. The slash command version returns parseable text output.

### 2. Slack Socket Mode Response Fix
- **File**: `src/sleepless_agent/interfaces/bot.py`
- **Change**: Refactored all response handling to use `chat_postMessage` API instead of `response_url`
- **Reason**: Socket Mode requires using the WebClient API for reliable message delivery. The response_url approach was failing silently.
- **Methods affected**:
  - `send_response()` - Complete refactor
  - `handle_slash_command()` - Updated to pass channel instead of response_url
  - `handle_think_command()` - Signature changed
  - `_create_task()` - Signature changed
  - `handle_check_command()` - Signature changed
  - `handle_cancel_command()` - Signature changed
  - `handle_trash_command()` - Signature changed
  - `handle_report_command()` - Signature changed

### 3. Configuration Updates
- **File**: `src/sleepless_agent/config.yaml`
- Time window: 10 PM - 7 AM (night_start_hour: 22, night_end_hour: 7)
- Extended thinking: max_thinking_tokens: 31999
- Fallback model: claude-opus-4-5-20251101

## Branch Strategy

- `main`: Production-ready code with custom modifications
- `upstream-sync`: (recommended) Branch for testing upstream merges before applying to main
- Feature branches: `feature/<description>` for new development

## Best Practices for Upstream Sync

When syncing with upstream, consider this workflow:

```bash
# Create a sync branch
git checkout -b upstream-sync
git fetch upstream
git merge upstream/main

# Test changes
./start.sh
# Run tests, verify Slack bot works, etc.

# If tests pass, merge to main
git checkout main
git merge upstream-sync
git push origin main

# Clean up
git branch -d upstream-sync
```

This ensures you can test upstream changes before applying them to your production main branch.

## Resolving Conflicts

If you encounter merge conflicts when syncing:

1. **Identify the conflict**: Git will mark conflicting sections in files
2. **Understand the change**: Review both versions (upstream vs your custom changes)
3. **Keep your customizations**: For the files listed above, prefer your fork's version
4. **Test thoroughly**: After resolving, test all functionality

Example conflict resolution for `pro_plan_usage.py`:

```python
<<<<<<< HEAD (your fork)
def __init__(self, command: str = "claude /usage"):
=======
def __init__(self, command: str = "claude usage"):
>>>>>>> upstream/main (original repo)
```

**Resolution**: Keep `"claude /usage"` (your fork's version) as it works with v2.0.69.

## Reporting Issues

- **Fork-specific issues**: Report here: https://github.com/rachittshah/sleepless-agent/issues
- **Upstream issues**: Report to original repo: https://github.com/context-machine-lab/sleepless-agent/issues

## Contributing Back to Upstream

If you make improvements that would benefit the original project:

1. Create a feature branch: `git checkout -b feature/my-improvement`
2. Make your changes
3. Push to your fork: `git push origin feature/my-improvement`
4. Create a Pull Request to `context-machine-lab/sleepless-agent`

## Version Compatibility

This fork is specifically designed for:
- **Claude Code CLI**: v2.0.69+
- **Python**: 3.11+
- **claude-agent-sdk**: 0.1.16+
- **Slack SDK**: 3.39.0+

## Maintenance Schedule

Recommended sync frequency: Monthly or when major updates are released to upstream.

Last synced with upstream: 2025-12-14
