# Bahboh

**Tagline:** Stack the glow. Clear the danger. Beat the clock.

Bahboh is a polished Flutter web puzzle game where glowing bubbles fall by gravity, players drag the active bubble into position, valid **OK** color groups score big, and **Not OK** bubbles annihilate on contact.

The goal is simple to read and hard to master: build the best legal board you can before time runs out or the screen fills up.

## Core Gameplay

- Glowing bubbles fall in three sizes
- Colors span the full ROYGBIV spectrum
- Each round defines:
  - **OK** color combinations
  - **Not OK** color combinations
- Players drag the active falling bubble before it locks into place
- Any **Not OK** bubble that touches any other **Not OK** bubble annihilates
- The best score comes from:
  - building strong **OK** formations
  - clearing danger efficiently
  - ending the round with minimal remaining **Not OK** bubbles

## Bahboh V1 Scope

- Flutter-first
- Web-first
- Single-player
- Timed puzzle gameplay
- Handcrafted and generated rounds
- Pause/resume support
- Local score + settings persistence
- SFX-first audio
- Optional haptics where supported
- No backend
- No auth
- No cloud save
- No monetization in v1

## Design Goals

Bahboh is being built to showcase modern AI-assisted application development with a premium visual experience:
- luminous jelly-like bubbles
- rich glow and impact feedback
- glassy futuristic HUD
- satisfying audio cues
- accessible reduced-motion and color-safe options

## Status

Bahboh is currently in governed preproduction / vertical-slice planning.

The gameplay law, scope boundary, and scoring direction are being locked before the first playable browser build.

## Stack

- Flutter
- Flutter Web
- Local persistence
- Governed through **8gentiC | Caris | Phoenix**

## Vision

Beautiful. Addicting. Readable. Fast.

Bahboh should feel easy to understand in seconds, satisfying to play in minutes, and difficult to put down.
