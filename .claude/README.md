# Claude Code Documentation

This directory contains documentation and changelogs from Claude Code development sessions.

## Structure

- `changelogs/` - Session-based changelogs organized by date
- `README.md` - This file

## Changelog Organization

Each development session gets its own changelog file named by date:
- `2025-10-04_weapon_melee_fixes.md` - Weapon attachment and melee system
- `2025-10-07_movement_improvements.md` - Crouch, strafing, grappling improvements
- `2025-10-12_current_session.md` - Current development session

## Finding Changes

To find when a specific feature was changed:
1. Check the main `CLAUDE_CHANGELOG.md` for a summary
2. Look in the date-specific changelog for full details
3. Use grep/search to find specific function names or files

## Adding New Entries

When starting a new session, create a new file in `changelogs/` with:
- Date in YYYY-MM-DD format
- Brief description of the session focus
- `.md` extension
