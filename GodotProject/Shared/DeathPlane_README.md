# DeathPlane - Usage Guide

## What is it?
A simple death plane that teleports the player to a respawn point when they fall out of bounds.

## Quick Setup

### Method 1: Using the Pre-made Scene (Easiest)

1. **Add the DeathPlane to your level:**
   - In your level scene, click "Instantiate Child Scene" (Ctrl+Shift+A)
   - Navigate to `res://Shared/DeathPlane.tscn`
   - Click "Open"

2. **Position the death plane:**
   - Select the DeathPlane node in the scene tree
   - Move it to below your level geometry (e.g., Y = -50)
   - The default size is 100x100 units - scale it if needed

3. **Add a respawn marker:**
   - Add a Marker3D node to your level (Add Child Node -> Marker3D)
   - Name it something like "PlayerSpawn" or "RespawnPoint"
   - Position it where you want the player to respawn

4. **Connect the respawn marker:**
   - Select the DeathPlane node
   - In the Inspector, find "Respawn Marker" property
   - Drag your Marker3D node into this property field

5. **Done!** Test by falling off the level.

### Method 2: Manual Setup

1. **Create an Area3D:**
   - Add Child Node -> Area3D
   - Name it "DeathPlane"

2. **Add collision:**
   - Add Child Node to Area3D -> CollisionShape3D
   - In Inspector, create a BoxShape3D
   - Scale the box to cover the area below your level

3. **Attach the script:**
   - Select the Area3D node
   - Click "Attach Script" button
   - Choose "Load" and select `res://Shared/DeathPlane.gd`

4. **Follow steps 3-5 from Method 1**

## Configuration

### Inspector Properties

- **Respawn Marker** (Marker3D): The location to teleport player to
  - If not set, player respawns at origin (0, 0, 0)

- **Reset Velocity** (bool): Whether to reset player velocity on respawn
  - Default: `true`
  - Recommended: Keep enabled to prevent player from carrying fall momentum

- **Play Respawn Sound** (bool): Whether to play a sound effect on respawn
  - Default: `false`
  - Enable if you want audio feedback

- **Respawn Sound** (AudioStream): The sound to play on respawn
  - Only used if "Play Respawn Sound" is enabled
  - Drag an audio file (.wav, .ogg) into this field

## Advanced Usage

### Multiple Respawn Points

You can have multiple DeathPlanes with different respawn points:

```
Level Scene
├── DeathPlane_MainArea (respawns to SpawnPoint_Main)
├── DeathPlane_SecretArea (respawns to SpawnPoint_Secret)
└── Markers
    ├── SpawnPoint_Main
    └── SpawnPoint_Secret
```

### Scaling the Death Plane

To cover your entire level:
1. Select the DeathPlane
2. In the Inspector, find "Transform -> Scale"
3. Adjust X and Z values (e.g., X=5, Z=5 for 500x500 units)

### Visual Indicator (Debug)

The death plane has a hidden visual indicator for debugging:
1. Select the DeathPlane node
2. Find "VisualIndicator" child node
3. Toggle "Visible" in Inspector to see the red transparent plane

## Tips

- **Position**: Place 10-20 units below your lowest walkable surface
- **Size**: Make it larger than your level bounds to catch all falls
- **Multiple planes**: Use several smaller planes rather than one huge one for performance
- **Respawn height**: Place respawn marker 1-2 units above ground to prevent spawning inside floor

## Collision Layers

The death plane is configured to:
- **Collision Layer**: 0 (not on any layer)
- **Collision Mask**: 1 (only detects Layer 1 = Player)

This means it only detects the player and ignores everything else.

## Troubleshooting

**Player isn't respawning:**
- Check that player is in "players" group or is Player class
- Verify respawn marker is set in Inspector
- Check collision mask is set to 1

**Player respawns at wrong location:**
- Verify you assigned the correct Marker3D
- Check the Marker3D's global position

**Player carries momentum after respawn:**
- Enable "Reset Velocity" in Inspector
