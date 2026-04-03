# Bahboh

**Tagline:** Stack the glow. Clear the danger. Keep the field alive.

Bahboh is a polished Flutter web puzzle game where glowing bubbles drift downward, players drag the active bubble before it locks, and danger colors annihilate on contact.

Created using 8gentiC | Caris | Phoenx

![Bahboh bubble mark](docs/images/baboh.gif)

The goal is simple to read and hard to master: build the best legal board you can before the bubbles reach the top.

## Core Gameplay

- The game opens on a splash screen with the Bahboh mark and a short play prompt
- Glowing bubbles fall in three visible sizes
- Colors span the full ROYGBIV spectrum
- Players can drag the active bubble horizontally before lock
- A small downward soft drop is available for faster descent
- Once a bubble locks, it becomes part of the board and can no longer be dragged
- Any **Not OK** bubble that touches any other **Not OK** bubble annihilates deterministically
- Level banners appear when the board advances to a new phase
- Combo recipes rotate as the level advances
- The board only ends when bubbles actually reach the top edge

## Bahboh V1 Scope

- Flutter-first
- Web-first
- Single-player
- Endless arcade puzzle gameplay with phase-based level banners
- Handcrafted round law and seeded replay support through the same round contract
- Pause/resume support
- Local score + settings persistence
- SFX-first audio
- Optional haptics where supported
- No backend
- No auth
- No cloud save
- No monetization in v1

## Design Goals

Bahboh is built to showcase a premium Flutter web presentation with:
- radioactive neon bubble art
- transparent membranes and strong glow
- lush board atmosphere and pop residue
- glassy futuristic HUD
- accessible reduced-motion and color-safe options

## Status

Bahboh is currently in a governed browser-playable build with a splash screen, soft-drop control, level banners, and locked gameplay law.

## Stack

- Flutter
- Flutter Web
- Local persistence
- Governed through **8gentiC | Caris | Phoenx**

## Vision

Beautiful. Addicting. Readable. Fast.

Bahboh should feel easy to understand in seconds, satisfying to play in minutes, and difficult to put down.
