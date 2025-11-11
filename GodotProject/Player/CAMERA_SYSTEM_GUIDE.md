# Camera System Guide

## Overview

The player camera system uses the **Phantom Camera** addon with a THIRD_PERSON follow mode. The camera has been enhanced with smooth damping, configurable mouse input, and runtime adjustability.

## Architecture

### Components

1. **CameraController** (`CameraController.gd`)
   - Main camera management script
   - Handles mouse input and applies rotation
   - Configures PhantomCamera3D settings
   - Provides runtime adjustment methods

2. **PhantomCamera3D** (PlayerCamera node)
   - Third-person follow camera with SpringArm3D
   - Handles positional and rotational smoothing
   - Manages collision detection and camera distance
   - Supports tween transitions between camera states

3. **MainCamera** (Camera3D)
   - The actual Godot camera node
   - Controlled by PhantomCameraHost
   - Automatically follows active PhantomCamera3D

## Configuration

### CameraController Export Variables

Located in `Player.tscn` → CameraController node inspector:

#### Mouse Input
- **mouse_sensitivity** (0.0 - 2.0): Base sensitivity multiplier
  - Default: `0.25`
  - Lower = slower camera rotation
  - Higher = faster camera rotation

- **mouse_acceleration** (bool): Enable velocity-based acceleration
  - Default: `false`
  - Makes camera more responsive to fast mouse movements

- **mouse_acceleration_factor** (1.0 - 3.0): Acceleration strength
  - Default: `1.5`
  - Only applies if mouse_acceleration is enabled

- **invert_mouse_y** (bool): Invert vertical mouse axis
  - Default: `false`

#### Camera Rotation Limits
- **min_pitch**: Minimum pitch angle (looking up)
  - Default: `-89.9`

- **max_pitch**: Maximum pitch angle (looking down)
  - Default: `50.0`

- **min_yaw**: Minimum yaw angle
  - Default: `0.0` (full rotation)

- **max_yaw**: Maximum yaw angle
  - Default: `360.0` (full rotation)

#### Camera Smoothing
- **enable_follow_damping** (bool): Enable position smoothing
  - Default: `true`
  - Provides smooth camera movement following player

- **follow_damping_value** (Vector3): Damping strength per axis
  - Default: `(0.15, 0.15, 0.15)`
  - Lower = smoother/slower (0.05 - 0.1)
  - Higher = snappier/faster (0.2 - 0.3)
  - X = horizontal, Y = vertical, Z = depth

- **enable_rotation_damping** (bool): Enable rotation smoothing
  - Default: `true`
  - Note: Currently applied via PhantomCamera internally

- **rotation_damping_value** (float): Rotation damping strength
  - Default: `0.1`
  - Lower = smoother rotation
  - Higher = snappier rotation

#### Camera Distance
- **camera_distance** (1.0 - 20.0): Distance from player
  - Default: `5.0`
  - SpringArm length

- **camera_height_offset** (-2.0 - 3.0): Vertical offset from player
  - Default: `1.5`
  - Positive = camera higher up
  - Negative = camera lower down

### PhantomCamera3D Settings

Located in `Player.tscn` → CameraController → PlayerCamera node:

#### Core Settings
- **priority**: `10` (higher priority cameras take control)
- **follow_mode**: `THIRD_PERSON` (uses SpringArm3D)
- **follow_target**: Player node

#### Follow Parameters
- **follow_offset**: `Vector3(0, 1.5, 0)` - Offset from player position
- **follow_damping**: `true` - Enable position smoothing
- **follow_damping_value**: `Vector3(0.15, 0.15, 0.15)` - Per-axis damping

#### Spring Arm
- **spring_length**: `5.0` - Camera distance from player
- **collision_mask**: `29` - Layers to collide with (walls, floors, etc.)
  - Prevents camera clipping through geometry
  - Automatically adjusts distance when blocked

#### Tweening
- **tween_resource**: PhantomCameraTween resource
  - **duration**: `1.0` seconds
  - **transition**: `TRANS_LINEAR` (0)
  - **ease**: `EASE_IN_OUT` (2)
- **tween_on_load**: `false` - Skip initial tween on scene load

## Tuning Guide

### Making Camera Feel "Heavier" (More Cinematic)
1. Increase `follow_damping_value` to `(0.25, 0.25, 0.25)` or higher
2. Decrease `mouse_sensitivity` to `0.15-0.20`
3. Enable `mouse_acceleration` with factor `2.0-2.5`

### Making Camera Feel "Snappier" (More Responsive)
1. Decrease `follow_damping_value` to `(0.05, 0.05, 0.05)` or lower
2. Increase `mouse_sensitivity` to `0.35-0.50`
3. Disable `mouse_acceleration`

### Different Damping Per Axis
You can set different damping values for each axis:
- `follow_damping_value = Vector3(0.1, 0.2, 0.15)`
  - X (horizontal): Very smooth (0.1)
  - Y (vertical): Slightly sluggish (0.2)
  - Z (depth): Balanced (0.15)

### Action Camera Feel (Ratchet & Clank style)
```
mouse_sensitivity = 0.3
mouse_acceleration = true
mouse_acceleration_factor = 1.8
follow_damping_value = Vector3(0.12, 0.15, 0.12)
camera_distance = 6.0
camera_height_offset = 1.8
```

### Tight Over-the-Shoulder
```
mouse_sensitivity = 0.4
mouse_acceleration = false
follow_damping_value = Vector3(0.08, 0.08, 0.08)
camera_distance = 3.5
camera_height_offset = 1.2
```

## Runtime Adjustments

The CameraController provides methods to adjust settings at runtime:

```gdscript
# Access camera controller
var camera_controller = player.camera_controller

# Adjust camera distance
camera_controller.set_camera_distance(7.0)

# Adjust height offset
camera_controller.set_camera_height_offset(2.0)

# Toggle damping
camera_controller.set_follow_damping_enabled(false)

# Adjust damping strength
camera_controller.set_follow_damping_strength(Vector3(0.2, 0.2, 0.2))

# Get PhantomCamera3D for advanced control
var pcam = camera_controller.get_phantom_camera()
pcam.set_spring_length(8.0)
```

## Advanced Features (Phantom Camera)

### Multiple Camera States

You can create multiple PhantomCamera3D nodes for different situations:
- Exploration camera (wide angle, further back)
- Combat camera (tighter, closer)
- Aiming camera (over-shoulder)
- Cutscene cameras (fixed positions)

Switch between them by changing priorities:
```gdscript
exploration_camera.set_priority(5)
combat_camera.set_priority(10)  # This becomes active
```

### Camera Shake / Noise

Add camera shake using PhantomCameraNoise3D resources:
```gdscript
var noise = PhantomCameraNoise3D.new()
noise.amplitude = 0.5
noise.frequency = 20.0
player_camera.set_noise(noise)
```

### Dead Zones (FRAMED mode)

For 2.5D or side-scrolling sections, switch to FRAMED mode:
```gdscript
var framed_camera = PhantomCamera3D.new()
framed_camera.follow_mode = PhantomCamera3D.FollowMode.FRAMED
framed_camera.dead_zone_width = 0.3
framed_camera.dead_zone_height = 0.2
```

### Look-At Targets

Make camera look at specific targets:
```gdscript
player_camera.look_at_mode = PhantomCamera3D.LookAtMode.SIMPLE
player_camera.set_look_at_target(enemy_node)
player_camera.look_at_damping = true
player_camera.look_at_damping_value = 0.15
```

## Common Issues

### Camera feels jittery
- Enable `follow_damping` if disabled
- Increase `follow_damping_value` (try 0.2+)
- Check that player physics is stable

### Camera too slow to respond
- Decrease `follow_damping_value` (try 0.05-0.1)
- Increase `mouse_sensitivity`
- Disable `mouse_acceleration`

### Camera clips through walls
- Adjust `collision_mask` on PlayerCamera
- Ensure wall collision layers are set correctly
- SpringArm3D will automatically pull camera closer when blocked

### Camera rotates too fast/slow
- Adjust `mouse_sensitivity` in CameraController
- Try enabling `mouse_acceleration` for dynamic feel
- Check that mouse input isn't being processed elsewhere

## References

- **Phantom Camera Documentation**: https://phantom-camera.dev/
- **Phantom Camera GitHub**: https://github.com/ramokz/phantom-camera
- **GDScript file**: `Player/CameraController.gd`
- **Scene configuration**: `Player/Player.tscn`

## Future Enhancements

Potential additions for even better camera feel:
1. **Field of View (FOV) changes** - Widen FOV during high-speed movement
2. **Dynamic camera distance** - Pull back during combat
3. **Context-sensitive cameras** - Automatically switch for different gameplay situations
4. **Camera shake presets** - Reusable shake patterns for explosions, impacts, etc.
5. **Smooth zoom** - Lerp between different camera distances
6. **Aim mode camera** - Tighter over-shoulder view when aiming
