# Player Refactoring Guide

## Overview
The Player class has been refactored to follow better software architecture principles with clear separation of concerns. The monolithic Player.gd has been split into several specialized manager classes.

## New Architecture

### Core Classes Created

#### 1. ActiveWeaponManager.gd
**Purpose**: Manages all weapon-related functionality
- Handles weapon switching between melee/ranged
- Manages active weapon slots
- Handles quick-select weapon switching
- Manages gadget temporary storage
- Initializes weapons from starting loadout

**Key Methods**:
- `equip_item(item: Item3D)` - Equip weapon/gadget
- `switch_to_melee_weapon()` / `switch_to_ranged_weapon()`
- `handle_quick_select(direction: String)`
- `get_current_weapon()` - Returns currently equipped weapon

#### 2. PlayerInputHandler.gd
**Purpose**: Handles all input processing and emits appropriate signals
- Processes movement input with camera orientation
- Handles action inputs (jump, attack, dodge, etc.)
- Manages strafe toggle state
- Separates input from game logic

**Key Signals**:
- `movement_input_changed(direction: Vector3)`
- `attack_pressed(attack_type: String)`
- `quick_select_pressed(direction: String)`

#### 3. PlayerCombatManager.gd
**Purpose**: Manages combat state and mechanics
- Handles melee combo system
- Manages attack timers and cooldowns
- Processes damage and knockback
- Coordinates with weapon manager for attacks

**Key Methods**:
- `try_attack(attack_type: String)` - Attempt attack
- `reset_combat_state()` - Reset combat state
- `take_damage(amount: float, impact_point: Vector3)`

#### 4. PlayerRefactored.gd
**Purpose**: Main player controller that coordinates all managers
- Lightweight coordinator class
- Handles physics and movement
- Connects manager signals
- Maintains player state flags

## Migration Steps

### 1. Scene Setup
Add the new manager nodes to your Player scene:
```
Player (CharacterBody3D)
├── PlayerInputHandler
├── ActiveWeaponManager  
├── PlayerCombatManager
├── (existing nodes...)
```

### 2. Export Assignments
In the Player scene, assign the exports for each manager:

**ActiveWeaponManager**:
- `player_hand` → PlayerHand node
- `character_skin` → CharacterSkin node  
- `inventory` → Inventory node

**PlayerCombatManager**:
- `attack_timer` → AttackTimer node
- `combo_timer` → ComboTimer node
- `weapon_manager` → ActiveWeaponManager node

**PlayerInputHandler**:
- `camera_controller` → CameraController node

### 3. Replace Player Script
1. Backup your current Player.gd
2. Replace Player.gd with PlayerRefactored.gd content
3. Update the class_name from `PlayerRefactored` to `Player`

### 4. Update State Machine
Update your player state scripts to use the new manager system:

```gdscript
# Instead of accessing player directly:
player.current_melee_weapon

# Use the weapon manager:
player.get_weapon_manager().get_melee_weapon()

# For attacks:
player.get_combat_manager().try_attack("melee")

# For input:
var input_direction = player.get_input_handler().get_camera_oriented_input()
```

## Benefits of Refactoring

### 1. Separation of Concerns
- Each class has a single responsibility
- Easier to maintain and debug
- Clear interfaces between systems

### 2. Improved Testability
- Each manager can be tested independently
- Mock objects can be used for testing
- Clearer dependencies

### 3. Better Code Organization
- Related functionality grouped together
- Reduced coupling between systems
- Easier to add new features

### 4. Maintainability
- Changes to weapon system don't affect input handling
- Combat changes don't affect movement
- Easier to understand and modify

## Breaking Changes

### Method Renames/Moves
- `put_in_hand()` → `weapon_manager.equip_item()`
- `handle_quick_select()` → `weapon_manager.handle_quick_select()`
- `_get_camera_oriented_input()` → `input_handler._get_camera_oriented_input()`
- Combat variables moved to `combat_manager`

### Signal Changes
- Input signals now come from `input_handler`
- Weapon signals come from `weapon_manager`
- Combat signals come from `combat_manager`

## Backward Compatibility

The refactored player maintains the same public interface where possible:
- `get_inventory()` still works
- `weapon_changed` signal still emitted
- State flags still accessible

## Testing Checklist

After implementing the refactoring:

- [ ] Player spawns correctly
- [ ] Movement input works
- [ ] Weapon switching works (melee/ranged)
- [ ] Quick select works
- [ ] Combat attacks work
- [ ] Gadgets work
- [ ] Inventory functions work
- [ ] State machine integration works
- [ ] All existing signals still fire

## Future Improvements

With this architecture, you can easily add:
- **PlayerMovementManager** - Handle movement physics
- **PlayerAnimationManager** - Coordinate animations
- **PlayerStatusManager** - Handle buffs/debuffs
- **PlayerAudioManager** - Handle audio cues

Each new manager follows the same pattern of handling a specific concern and communicating via signals.
