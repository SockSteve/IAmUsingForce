# Claude Code Changelog

This is a summary changelog. For detailed session-specific changes, see `.claude/changelogs/`

---

## Recent Sessions

### 2025-10-12: Movement & Grappling Hook Improvements
**Focus:** Slide physics, ledge grab overhaul, grappling hook optimization & enhancements

**Key Changes:**
- Fixed slide physics: removed gravity from air slides, added airborne jump
- Completely overhauled ledge grab system (detection, positioning, multiple exits)
- Optimized grappling hook detection with distance checks + visibility culling (10-100x faster)
- Fixed grappling hook activation via gadget button
- Added velocity-based pull-in mechanic (50 units/sec) with Ratchet & Clank feel
- Implemented toggleable debug visualization (G key) showing detection radius and target distance
- Fixed Nil errors, joint timing issues, and swing mechanics
- Tuned joint limits to ±20 units (40-unit diameter swing sphere)

**Files Modified:** Player states (Crouch, Air, LedgeHang, Grapple), GrapplingHook, GrapplePoint, Player.gd, project.godot

**Details:** See `.claude/changelogs/2025-10-12_current_session.md`

---

### 2025-10-07: Player Refactoring & Polish
**Focus:** Grappling hook, drop shadow, collision recovery, slide improvements

**Key Changes:**
- Fixed grappling hook after player refactoring with enhanced physics
- Added momentum conservation and launch boost (1.5x)
- Implemented dynamic drop shadow with raycast and distance fading
- Added anti-stuck collision recovery system
- Improved slide ground-sticking on uneven terrain

**Details:** See `.claude/changelogs/2025-10-07_movement_improvements.md`

---

### 2025-10-04: Weapon & Combat Systems
**Focus:** Weapon attachment, melee system, crouch state, strafing

**Key Changes:**
- Fixed weapon attachment to proper skeleton bone sockets
- Integrated melee attack system with state machine
- Refactored crouch state for new player structure
- Overhauled strafing system to prevent instant camera snap

**Details:** See `.claude/changelogs/2025-10-04_weapon_melee_fixes.md`

---

## Changelog Organization

Starting from 2025-10-12, detailed changelogs are organized in `.claude/changelogs/` by date:

- `2025-10-12_current_session.md` - Current session (slide, ledge, grappling)
- `2025-10-07_movement_improvements.md` - Movement polish and systems
- `2025-10-04_weapon_melee_fixes.md` - Weapon and combat work

Each file contains:
- Full technical details
- Before/after code comparisons
- Architecture explanations
- All modified files and line numbers

---

## Quick Reference

### Finding Changes
1. Check this file for session summaries
2. Look in `.claude/changelogs/YYYY-MM-DD_*.md` for full details
3. Use grep/search for specific functions or files

### Adding New Sessions
When starting a new session:
1. Create new file in `.claude/changelogs/` with date + description
2. Document all changes in that file
3. Add summary entry to this file under "Recent Sessions"

---

## Major Systems Worked On

### Player Movement
- State machine (Idle, Run, Air, Crouch, Dodge, Melee, Grapple, LedgeHang, Grind)
- Collision recovery and anti-stuck system
- Slide physics with ground-sticking and air momentum
- Ledge grab detection and climbing
- Strafing system with smooth camera orientation

### Combat
- Weapon attachment to skeleton bones
- Melee attack integration with state machine
- Weapon manager for switching and inventory
- Combat manager for attack coordination

### Gadgets
- Grappling hook with distance-based detection
- Visibility culling for performance
- Active/passive gadget patterns
- Inventory integration

### Visual Polish
- Dynamic drop shadow with raycast
- Distance-based fading
- Proper decal projection

---

For the full historical changelog with all details, see git history or the archived version at `CLAUDE_CHANGELOG_ARCHIVE.md` (if it exists).
