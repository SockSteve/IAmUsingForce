# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"I Am Using Force" is a 3D action game built with Godot 4.5 using GDScript. The game features a player character with parkour abilities, combat systems, enemies with AI state machines, and various weapon types (melee and ranged).

## Project Structure

The main project files are located in the `GodotProject/` directory:

- **Player/**: Player character controller with state machine-based movement and combat
- **Enemies/**: Enemy AI systems and various enemy types organized by categories (Common/, Boss/, Shared/)
- **Weapons/**: Weapon systems split into MeleeWeapons/ and RangedWeapons/
- **Levels/**: Game levels and scenes (main scene: `Levels/Test.tscn`)
- **Singletons/**: Global systems and managers (autoloaded)
- **SpecialFX/**: Visual effects and shaders
- **UI/**: User interface components
- **Assets/**: Models, textures, audio, and animations
- **Gadgets/**: Player gadgets and equipment
- **Interactibles/**: Interactive objects in the game world

## Architecture

### Singleton Systems (Autoloaded)
- `Globals.gd`: Game progression flags and state management
- `SignalBus.gd`: Global signal communication hub
- `GameHandler`: Main game management scene
- `DebugLibrary`: Development debugging tools
- `HelperLibrary`: Utility functions
- `ObjectContainer`: Bullet and projectile management
- `InstanceLoader`: Dynamic instance loading
- `DebugMenu`: In-game debug interface

### Core Systems

**Player System**: Uses a state machine architecture (`Player/States/`) with states like Idle, Run, Air, Dodge, Melee, Grapple, etc. The main player controller (`Player.gd`) manages movement, combat, and inventory.

**Enemy System**: Base enemy class (`Enemies/Common/EnemyBase.gd`) with HP components and stagger mechanics. Individual enemies extend this base with their own AI behaviors.

**Weapon System**: Base weapon class (`Weapons/Weapon.gd`) with leveling, XP, and upgrade systems. Weapons are categorized as melee or ranged with their own bullet/projectile systems.

**Physics Layers**: Defined layer system for different entity types:
- Layer 1: Player
- Layer 2: Enemy  
- Layer 3: Collectible
- Layer 4: Destructible
- Layer 5: Wall
- Layer 6: Floor
- Layer 7: Platform
- Layer 8: Interactible
- Layer 9: Player bullets
- Layer 10: Enemy bullets
- Layer 11: Money

## Development Commands

The project uses Godot 4.5 with Jolt Physics engine. Open the project by importing `GodotProject/project.godot` in Godot Editor.

### Running the Game
- Open `GodotProject/project.godot` in Godot 4.5+
- Main scene is set to `res://Levels/Test.tscn`
- Press F5 or use the play button in Godot Editor

### Enabled Addons
- GPUTrail: GPU-based trail effects
- phantom_camera: Advanced camera system
- ridiculous_coding: Development enhancement
- script-ide: Script editing improvements

## Input Controls

The game supports both keyboard/mouse and gamepad controls:
- WASD: Movement
- Space: Jump
- F/Left Click: Melee attack
- Right Click: Ranged attack
- Shift: Dodge
- E: Gadget/Interact
- C/Ctrl: Crouch
- Arrow keys: Quick select
- Tab: Quick select panel change

## Conventions

- Use GDScript for all game logic
- Class names use PascalCase (e.g., `class_name Player`)
- Files use snake_case naming
- Signals use snake_case (e.g., `weapon_changed`)
- Export variables are grouped and documented
- Use typed variables where possible (`: Type`)
- Comment complex systems and public interfaces

## Key Features

- State machine-based player movement system
- Leveling and upgrade system for weapons
- Enemy AI with stagger and HP systems
- Parkour mechanics (grappling, grinding, wall climbing)
- Physics-based combat with different damage types
- Game progression flag system
- Modular weapon and enemy systems