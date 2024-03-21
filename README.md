# Aseprite Hitbox Editor
A lua script for Aseprite for easily creating usable hitbox data for pixel art animations. 

### Toolbar Functionality

- add
  - Create New Hitbox in its own Layer
- insert
  - Create Frame for current hitbox
- edit
  - Modify existing hitbox data
- hide/show
  - toggle visibility of selected hitbox layer
- settings
  - export
    - create simple JSON representation of hitbox data easily mappable to animation frames by frame number
  - import
    - load in a JSON file with hitbox data and create a corresponding Hitbox_Data group with its layers

### Hitboxes
- Persistent properties (over hitbox lifetime):
  - Damage (float)
  - HitCount (int) 
    - times hitbox can activate per target per one activation
  - isMultihit (property: bool) => HitCount > 1
  - isSinglehit (property: bool) => HitCount == 1;

<p></p>

- Dynamic properties (Can change on each frame):
  - size (px)
    - **w:** horizontal width
    - **h:** vertical height
  - position (px)
    - (x, y) coordinate relative to the sprite canvas
    - origin (0, 0) in the top left corner
  - Knockback (Vector2)

<p></p>

- Customization of hitboxes:
  - Style: Hitboxes can be assigned any color and transparency.
  - Shape: "boxes" can be rectangles or circles.

## TERMS, and how hitboxes even work:

- **HITBOX:** The attacking area of an offensive action. Attacks have different hit types: Strike, Projectile, Grab, Wind.
  
  - Strike: **HIGH**
  
  | | Standers | Crouchers |
  | - | - | - |
  |**HIT:**| ✅ | ❌ |
  |**BLOCK:**| ✅ | ❌ |
  |**EVADE:**| ❌ | ✅ |
  
    
  - Strike: **MID** / Overhead / Aerial  
  
  | | Standers | Crouchers |
  | - | - | - |
  |**HIT:**| ✅ | ✅ |
  |**BLOCK:**| ✅ | ❌ |
  |**EVADE:**| ❌ | ❌ |
    
  - Strike: **LOW**

  | | Standers | Crouchers |
  | - | - | - |
  |**HIT:**| ✅ | ✅ |
  |**BLOCK:**| ❌ | ✅ |
  |**EVADE:**| Jump⬆ | Jump⬆ |
  
    - Projectile
      - separates hitbox from hurtbox
      - hit count, "HP" per projectile
    - Grab
      - Bypasses blocking checks
      - Often counts as a **HIGH** attack, dodged by crouch
    - Wind
      - Damage = 0 (usually)
      - HitStun = 0
      - Knockback > 0

<p></p>

- **HURTBOX:** The hittable area of a character. An action happens when a **hitbox** makes contact with a **hurtbox** in the correct context. Hurtboxes have several different mode states they can be in.
  - Mode: Vulnerable (default)
  - Mode: Blocking
  - Mode: Invincible

<p></p>

- **KNOCKBACK:** The measure of how far an attack sends its target. The amount of *knockback* directly affects the amount of **hitstun**. Being a Vector2, it has both a direction and a magnitude / intensity.

<p></p>

- **STUN:** Attacks inflict a stunned animation on those that they hit, either **hitstun** or **blockstun**. This *stun* animation will interrupt whatever animation is currently playing, even if that animation is *stun*. In most games, the **hitstun** and **blockstun** animations are different durations, with **hitstun** usually being longer than **blockstun**.
  - **HITSTUN:** (known as DamageFly internally in Smash) is a period of time after being hit by an attack that a character is unable to act outside of directional influence or teching. Each Smash game has a programmed value that is multiplied by the amount of knockback received to determine the amount of frames a character is locked in hitstun after being hit; for example, Melee has a hitstun multiplier of 0.4 frames per unit of knockback, so a hit that deals 100 units of knockback will leave the target in hitstun for 40 frames.
  - **BLOCKSTUN:** The period of time when your character cannot perform any action after blocking an attack. In other words, blockstun occurs when an attack connects but is guarded against. Usually activated by strike and projectile hitboxes.

<p></p>

- **WINDBOX:** Windboxes are hitboxes that deal knockback, but cause no hitstun. As a purely aesthetic conceit, windboxes will also make certain parts of a character, such as Link's cap, respond realistically to the wind. Windboxes are typically non-damaging.
- **GRAB:** Grabs generally cannot be used on an opponent in hitstun or blockstun, though they are capable of beating Super Armor. During a throw animation, both characters are invincible to any other forms of hitboxes, letting certain mixups and scenarios be avoided if a player starts a throw at the proper time. Command Grabs are a variant of grabs that require an input in exchange for larger ranges, more damage, or better advantage on recovery.


- **STAGES of attack:**
  - **STARTUP:** The first phase of an attack, the period of time (measured in frames) that occurs after pressing your attack button, but before your attack is capable of making contact with the opponent, a.k.a. the "wind-up" of an action beofre the hitbox is out.
  - **ACTIVE:** The second phase of an attack, the period of time that a move has a live hitbox and is capable of doing damage to the opponent. Despite the active frames being the only time a move can do damage, it makes up a surprisingly small percentage of a move's total duration; usually moves only have around 1-4 active frames, even though the move itself might take 30 frames from start to finish. 
  - **RECOVERY:** The third and final phase of an attack, the period of time that occurs after your attack has finished hitting, but before you gain back control of your character for more actions. Your character is finishing the follow-through and usually left wide open if you whiffed. In other words, it is the time after the hitbox is out before you return to idle.

<p></p>

- **Retaliation Types:**
  - **COUNTER:** An attack that interrupts another attack's **startup** window.
  - **PUNISH:** An attack that interrupts another attack's **recovery** window.


Other detailed hitbox interaction information:

https://critpoints.net/2023/02/20/frame-data-patterns-that-game-designers-should-know/

https://streetfighter.fandom.com/wiki/Hurtbox

https://streetfighter.fandom.com/wiki/Hitbox

https://www.ssbwiki.com/Hitstun

https://www.ssbwiki.com/Knockback

https://www.ssbwiki.com/Windbox

https://glossary.infil.net/?t=Startup

https://glossary.infil.net/?t=Active

https://glossary.infil.net/?t=Recovery





