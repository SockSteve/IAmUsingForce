# State Machine Update Guide

## Overview
The player state machine has been updated to work with the new manager-based architecture and includes coyote time functionality for better jumping mechanics.

## Key Changes

### 1. Manager Integration
- States now work with the new `ActiveWeaponManager`, `PlayerInputHandler`, and `PlayerCombatManager`
- Input is handled through signals from the input handler rather than direct Input checks
- Weapon switching and combat logic delegated to appropriate managers

### 2. Coyote Time Implementation
**What is Coyote Time?**
Coyote time allows players to jump for a brief moment (0.1 seconds by default) after leaving a platform, making jumping feel more responsive and forgiving.

**How it works:**
- Timer starts when player leaves the ground (`was_on_floor` becomes false)
- Player can jump during this grace period even if not technically on the ground
- Timer is consumed when used, preventing multiple coyote jumps

### 3. Updated State Methods

#### New Input Handler Methods
States can now implement these methods to handle input from the manager system:

```gdscript
func handle_jump() -> void:
    # Handle jump input
    
func handle_attack(attack_type: String) -> void:
    # Handle attack input (melee/ranged)
    
func handle_crouch() -> void:
    # Handle crouch input
    
func handle_dodge() -> void:
    # Handle dodge input
```

#### Coyote Time Methods (StateMachine)
```gdscript
func can_coyote_jump() -> bool:
    # Returns true if coyote time is active
    
func use_coyote_jump() -> void:
    # Consumes coyote time
```

## Updated States

### StateMachine.gd
- Added coyote time tracking variables
- Added input handler methods that delegate to current state
- Added `_update_coyote_time()` method called each physics frame

### Idle.gd
- Uses `player.move_direction` instead of direct input polling
- Implements `handle_jump()`, `handle_attack()`, `handle_crouch()`
- Includes coyote time check in jump handler

### Run.gd
- Updated to use new movement input system
- Implements input handler methods
- Coyote time support for jumping while running

### Air.gd
- Added coyote time jump functionality in `handle_jump()`
- Updated movement logic to use new input system
- Cleaner gadget state checking

## Property Updates

### Player Properties Used
States now reference these updated player properties:
- `player.move_direction` - Movement input from input handler
- `player.character_skin` - Updated reference (was `_character_skin`)
- `player.camera_controller` - Updated reference (was `_camera_controller`)
- `player.gravity` - Updated reference (was `_gravity`)
- `player.last_strong_direction` - Updated reference (was `_last_strong_direction`)

### Methods Used
- `player.is_strafing()` - Now a method call instead of property
- `player.orient_character_to_direction()` - Updated method name

## Coyote Time Configuration

You can adjust coyote time in the StateMachine:
```gdscript
# In StateMachine.gd
var coyote_time_duration: float = 0.1  # Adjust this value
```

**Recommended values:**
- `0.05` - Very tight timing (competitive)
- `0.1` - Default (feels responsive)
- `0.15` - Forgiving (easier for casual players)

## Benefits

### 1. Better Jump Feel
- Players can jump slightly after leaving platforms
- Reduces frustration from "missed" jumps
- More responsive platforming experience

### 2. Cleaner Architecture
- Input handling separated from state logic
- States focus on game logic rather than input polling
- Easier to modify input mappings

### 3. Better Debugging
- Clear separation between input detection and state response
- Easier to track state transitions
- Manager-based logging possibilities

## Migration Checklist

When updating other states:

- [ ] Replace direct `Input.is_action_*` calls with handler methods
- [ ] Update player property references (remove `_` prefixes)
- [ ] Implement appropriate `handle_*` methods
- [ ] Use `player.move_direction` for movement input
- [ ] Add coyote time support to jump logic where appropriate
- [ ] Test state transitions work correctly

## Future Enhancements

With this foundation, you can easily add:
- **Double Jump**: Track jump count and allow second jump in Air state
- **Jump Buffering**: Store jump input and execute when landing
- **Wall Jump**: Detect wall contact and allow jumping from walls
- **Variable Jump Height**: Adjust jump based on input duration
- **Jump Forgiveness**: Slightly extend platform collision for easier landings

The modular architecture makes these additions straightforward to implement.