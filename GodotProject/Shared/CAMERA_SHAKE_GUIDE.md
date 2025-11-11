# Camera Shake System Guide

## Overview

The camera shake system uses Phantom Camera's **PhantomCameraNoiseEmitter3D** to create localized, realistic camera shake effects. When objects are hit by bullets or other impacts, they can emit camera shake that affects nearby cameras based on distance.

## Components

### 1. CameraShakeEmitter

**File:** `Shared/CameraShakeEmitter.gd`

A reusable component that can be attached to any Node3D to emit camera shake. It dynamically creates a PhantomCameraNoiseEmitter3D and provides convenient methods for triggering shake.

**Key Features:**
- Configurable amplitude, frequency, and duration
- Distance-based attenuation (shake decreases with distance)
- Layer-based filtering (only affects cameras listening to specific layers)
- Preset shake types (light, medium, heavy, explosion)
- Optional debug visualization

**Export Variables:**
```gdscript
shake_amplitude: float = 0.3        # How far camera moves (0.0 - 2.0)
shake_frequency: float = 30.0       # How fast it oscillates (0.0 - 100.0)
shake_duration: float = 0.3         # How long shake lasts (0.0 - 5.0)
decay_rate: float = 3.0             # How quickly shake fades (0.0 - 10.0)
max_distance: float = 20.0          # Maximum distance shake travels (0.0 - 100.0)
noise_emitter_layer: int = 1        # Which layer to emit on
show_debug_sphere: bool = false     # Visual feedback
```

**Usage:**
```gdscript
# Add to any node
var shake_emitter = CameraShakeEmitter.new()
add_child(shake_emitter)

# Emit custom shake
shake_emitter.emit_shake(0.5, 0.4)  # amplitude, duration

# Use presets
shake_emitter.emit_light_shake()
shake_emitter.emit_medium_shake()
shake_emitter.emit_heavy_shake()
shake_emitter.emit_explosion_shake()

# Stop shake early
shake_emitter.stop_shake()
```

### 2. ShootableTarget

**File:** `Shared/ShootableTarget.gd`
**Scene:** `Shared/ShootableTarget.tscn`

A ready-to-use shootable object that automatically emits camera shake when hit by bullets. Great for target practice, destructible objects, or interactive environments.

**Features:**
- Automatic collision detection with bullets
- Built-in camera shake emission
- Optional health/destruction system
- Visual hit feedback (mesh flash)
- Configurable shake presets
- Signals for hit and destroyed events

**Export Variables:**
```gdscript
# Visual
mesh: Mesh                          # Custom mesh
material: Material                  # Custom material

# Behavior
destructible: bool = false          # Can be destroyed
max_health: int = 100              # Health points

# Camera Shake
enable_shake: bool = true          # Enable shake on hit
shake_type: int = 1                # 0=Light, 1=Medium, 2=Heavy, 3=Explosion
use_custom_shake: bool = false     # Override preset
custom_amplitude: float = 0.3
custom_duration: float = 0.3

# Debug
show_hit_effects: bool = true      # Flash on hit
```

**Signals:**
```gdscript
signal hit(position: Vector3, normal: Vector3)
signal destroyed
```

**Usage:**
```gdscript
# Add to scene
var target = ShootableTarget.new()
add_child(target)

# Connect signals
target.hit.connect(_on_target_hit)
target.destroyed.connect(_on_target_destroyed)

# Trigger shake manually
target.trigger_shake()
```

## Setup Guide

### Step 1: Configure Camera to Receive Shake

The PlayerCamera PhantomCamera3D needs to listen to shake emissions.

**In Player.tscn:**
1. Select `CameraController → PlayerCamera` node
2. Set `noise_emitter_layer` to `1` (or your chosen layer)

This is already configured in the improved camera system!

### Step 2: Add ShootableTarget to Scene

**Method A: Use Existing Scene**
1. In scene tree, right-click and "Instantiate Child Scene"
2. Select `res://Shared/ShootableTarget.tscn`
3. Position in world
4. Adjust settings in inspector

**Method B: Create from Script**
```gdscript
var target = preload("res://Shared/ShootableTarget.tscn").instantiate()
target.position = Vector3(5, 0, 0)
target.shake_type = 2  # Heavy shake
add_child(target)
```

### Step 3: Test with Gun

1. Run the game
2. Shoot the target with your gun
3. Camera should shake based on configured settings
4. Adjust shake_type or custom settings to tune feel

## How It Works

### Localized Shake System

```
Bullet hits ShootableTarget
  ↓
ShootableTarget calls on_bullet_hit()
  ↓
CameraShakeEmitter emits noise
  ↓
PhantomCameraNoiseEmitter3D broadcasts
  ↓
PlayerCamera receives shake (if in range and on correct layer)
  ↓
Camera shakes with amplitude decreasing by distance
```

### Distance Attenuation

Shake strength = `base_amplitude * (1 - distance / max_distance)`

Example:
- Base amplitude: 0.5
- Max distance: 20.0
- At 0 units: 0.5 amplitude (100%)
- At 10 units: 0.25 amplitude (50%)
- At 20+ units: 0.0 amplitude (0%)

### Layer System

Camera shake uses a layer system similar to collision layers:
- **Emitter layer**: Which layers the emitter broadcasts to
- **Camera layer**: Which layers the camera listens to
- Shake only affects cameras with matching layers

**Example Use Cases:**
- Layer 1: General gameplay shake (explosions, impacts)
- Layer 2: Player-specific shake (damage, melee attacks)
- Layer 3: Cutscene shake (scripted events)
- Layer 4: Environmental shake (earthquakes, machinery)

## Shake Presets

### Light Shake
```gdscript
amplitude = 0.1
duration = 0.2
frequency = 25.0
```
**Use for:** Small impacts, bullet hits on light objects, footsteps

### Medium Shake (Default)
```gdscript
amplitude = 0.3
duration = 0.3
frequency = 30.0
```
**Use for:** Normal bullet impacts, melee attacks, medium explosions

### Heavy Shake
```gdscript
amplitude = 0.6
duration = 0.5
frequency = 35.0
```
**Use for:** Large impacts, powerful weapons, boss attacks

### Explosion Shake
```gdscript
amplitude = 1.0
duration = 0.7
frequency = 40.0
```
**Use for:** Explosions, massive impacts, environmental destruction

## Advanced Usage

### Custom Shake Emitter

Create a custom emitter on any object:

```gdscript
extends Node3D

var shake_emitter: CameraShakeEmitter

func _ready():
	shake_emitter = CameraShakeEmitter.new()
	shake_emitter.shake_amplitude = 0.4
	shake_emitter.shake_frequency = 35.0
	shake_emitter.shake_duration = 0.4
	shake_emitter.max_distance = 15.0
	add_child(shake_emitter)

func explode():
	shake_emitter.emit_shake()
```

### Multiple Shake Types

Different shake for different hit types:

```gdscript
func on_bullet_hit(bullet, pos, normal):
	if bullet.is_explosive:
		camera_shake_emitter.emit_explosion_shake()
	elif bullet.is_heavy:
		camera_shake_emitter.emit_heavy_shake()
	else:
		camera_shake_emitter.emit_medium_shake()
```

### Distance-Based Shake Intensity

Adjust shake based on distance from player:

```gdscript
func emit_distance_adjusted_shake(player_pos: Vector3):
	var distance = global_position.distance_to(player_pos)
	var normalized_distance = clampf(distance / max_distance, 0.0, 1.0)
	var amplitude = lerp(1.0, 0.1, normalized_distance)
	shake_emitter.emit_shake(amplitude, 0.3)
```

### Continuous Shake (Machinery, Earthquake)

```gdscript
func start_continuous_shake():
	shake_emitter.shake_duration = -1  # Infinite
	shake_emitter.emit_shake()

func stop_continuous_shake():
	shake_emitter.stop_shake()
```

## Tuning Guide

### Too Much Shake
- Decrease `shake_amplitude` (0.1 - 0.2)
- Decrease `shake_duration` (0.1 - 0.2)
- Decrease `max_distance`
- Use lighter presets

### Not Enough Shake
- Increase `shake_amplitude` (0.5 - 1.0)
- Increase `shake_duration` (0.5 - 1.0)
- Increase `max_distance`
- Use heavier presets

### Shake Feels "Wrong"
- Adjust `shake_frequency`:
  - Low (10-20): Slow, earthquake-like
  - Medium (25-35): Natural impact feel
  - High (40-60): Rapid, intense vibration
- Adjust `decay_rate`:
  - Low (1-2): Gradual fadeout
  - High (5-10): Quick fadeout

### Shake Doesn't Work
1. Check `noise_emitter_layer` matches between emitter and camera
2. Verify camera is within `max_distance`
3. Ensure PlayerCamera has `noise_emitter_layer = 1` set
4. Check ShootableTarget is on correct collision layer (4)
5. Verify bullet collision mask includes layer 4

## Performance Notes

- Camera shake uses Phantom Camera's built-in noise system (very efficient)
- PhantomCameraNoiseEmitter3D automatically handles distance checks
- No performance impact when shake is not active
- Multiple emitters can be active simultaneously

## Common Patterns

### Destructible Barrel
```gdscript
var barrel = ShootableTarget.new()
barrel.destructible = true
barrel.max_health = 50
barrel.shake_type = 3  # Explosion
barrel.destroyed.connect(func(): spawn_explosion())
```

### Interactive Button
```gdscript
var button = ShootableTarget.new()
button.destructible = false
button.shake_type = 0  # Light
button.hit.connect(func(pos, normal): activate_door())
```

### Boss Weak Point
```gdscript
var weak_point = ShootableTarget.new()
weak_point.shake_type = 2  # Heavy
weak_point.use_custom_shake = true
weak_point.custom_amplitude = 0.8
weak_point.hit.connect(func(pos, normal): boss_take_damage())
```

## Future Enhancements

Potential additions:
1. **Directional shake** - Shake in direction of impact
2. **Shake curves** - Custom amplitude curves over time
3. **Combo shake** - Multiple shake types combined
4. **Shake pools** - Limit maximum concurrent shakes
5. **Audio-reactive shake** - Shake synced to audio
6. **Shake modifiers** - Multiply shake by player state (e.g., reduce when aiming)

## References

- **Phantom Camera Noise Docs**: https://phantom-camera.dev/follow-modes/third-person
- **CameraShakeEmitter Script**: `Shared/CameraShakeEmitter.gd`
- **ShootableTarget Script**: `Shared/ShootableTarget.gd`
- **ShootableTarget Scene**: `Shared/ShootableTarget.tscn`
