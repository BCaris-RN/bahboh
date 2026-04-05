# Bahboh

**Tagline:** Stack the glow. Clear the danger. Keep the field alive.

Bahboh is a polished Flutter web puzzle game where glowing bubbles drift downward, players drag the active bubble before it locks, and danger colors annihilate on contact.

Created using 8gentiC | Caris | Phoenix
by Caris Industries

8gentiC - Agentic workflow where agents cover every aspect of the SDLC
Caris - A deterministic governance-first layer adressing anti-slop, halucination etc. keeping AI models in strict form
Phoenix - Runtime layer executing and orchestrating the 8gentiC and Caris protocols

Live site: https://bcaris-rn.github.io/bahboh/

![Bahboh bubble mark](docs/images/baboh.gif)


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

## Addendum — Current Status and Direction

Bahboh has already moved beyond the original early concept. What started as a timed round-based puzzle with explicit player instructions is now evolving into a more compelling endless arcade puzzle experience built around score-chasing, visual satisfaction, and discovery.

### Where We Are Now

The game has a real playable core.

Bahboh is currently being shaped into an endless browser-first Flutter game where glowing bubbles fall, players drag and position them, hidden color-set combinations trigger explosive clears, and the goal is simply to survive as long as possible while building the highest score possible.

The core direction is now much clearer:

- no timer-driven pressure as the main mechanic
- no overexplained instruction-heavy round flow
- no rigid one-note combo system
- infinite-style gameplay with shifting hidden set logic
- score as the primary objective
- the board itself becoming a canvas of color, glow, residue, and chain reactions

We have already identified what is working and what is not.

What is working:
- the endless score-chase concept
- the hidden-combo discovery loop
- the feeling of dragging and placing falling bubbles
- the visual potential of the glowing bubble field
- the idea that successful clears should leave beautiful glowing residue behind

What still needs improvement:
- bubble physics still need to feel softer, floatier, and more bubble-like
- visual abundance needs to increase dramatically
- the game needs stronger level-up presentation and combo rotation
- GitHub Pages deployment is still being finalized
- the codebase needs cleanup and modularization after rapid prototyping

### What Bahboh Is Becoming

Bahboh is not meant to feel like a sterile puzzle board or a generic falling-ball game.

The target experience is:

- beautiful
- addictive
- readable
- reactive
- high-energy
- easy to start
- difficult to master

The bubbles should feel radioactive, transparent, luminous, and alive. The board should feel like a dark premium canvas that gets painted by glowing explosions and color residue over time. The player should not need a long explanation to play. They should experiment, discover patterns, chase score, and keep going.

### Current Design Direction

The current intended gameplay loop is:

1. bubbles continuously fall into the field
2. the player drags active bubbles into position
3. hidden color combinations create explosive clears
4. successful clears add score and create visual beauty on the board
5. enough successful clears advances the level
6. each new level changes the active combo logic
7. the game continues until the stack reaches the top

This makes Bahboh less about “beating a puzzle” and more about “staying alive, learning the field, and chasing mastery.”

### Where We Want To Go Next

Near-term priorities:

- finish stabilizing the endless gameplay loop
- improve bubble motion so early gameplay feels floaty and elegant
- make the three bubble sizes visually unmistakable
- increase on-screen richness with atmospheric bubbles, glow, and residue
- improve level-up feedback with stronger visual presentation
- finalize top-of-board game-over behavior
- get the project live on GitHub Pages

After that, the next layer is polish and retention:

- better sound effects and haptics
- stronger visual FX for explosions and chain reactions
- local best-score persistence
- cleaner code structure beyond the initial prototype pass
- optional accessibility and presentation refinements

### Long-Term Vision

Bahboh should become a browser game that feels premium, modern, and memorable.

Not just “a Flutter game.”
Not just “a puzzle prototype.”
Not just “a falling bubble mechanic.”

The goal is a distinctive arcade-puzzle experience with a visual identity strong enough to stand on its own:
a glowing, evolving, endless color field where every good play feels rewarding and every session can turn into a score chase.

### Honest Status

Bahboh is currently in active prototype-to-playable transition.

The concept is no longer vague.  
The core loop is becoming fun.  
The artistic direction is now much more clearly defined.  
The next major milestone is a stable, polished browser-playable build hosted publicly.

That is the immediate target.
