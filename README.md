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
- On each frame:
  - size (px)
    - width
    - height
  - position (px)
    - (x,y) coordinate relative to the sprite canvas, (0,0) in the top left
  - Knockback (Vector)
    - Knockback is the measure of how far an attack sends its target.
    - Hitstun: Hitstun (known as DamageFly internally) is a period of time after being hit by an attack that a character is unable to act outside of directional influence or teching. Each Smash game has a programmed value that is multiplied by the amount of knockback received to determine the amount of frames a character is locked in hitstun after being hit; for example, Melee has a hitstun multiplier of 0.4 frames per unit of knockback, so a hit that deals 100 units of knockback will leave the target in hitstun for 40 frames.
- Customizable hitbox types, with some templates to start from:
  - Hurtbox
    - the hitable area of a character
    - An action happens when a hitbox makes contact with a hurtbox in the correct context.
    - States:
      - Startup
      - Active
  - Hitbox
    - Type:
      - Strike
        - High (some + aerial)
          - Cannot be blocked low
          - Overhead? (grounded)
        - Low
          - Cannot be blocked standing
      - Projectile
        - separates hitbox from hurtbox
        - hit count, "HP" per projectile
      - Grab
        - Bypasses blocking
        - Grabs generally cannot be used on an opponent in hitstun or blockstun, though they are capable of beating Super Armor. During a throw animation, both characters are invincible to any other forms of hitboxes, letting certain mixups and scenarios be avoided if a player starts a throw at the proper time. Command Grabs are a variant of grabs that require an input in exchange for larger ranges, more damage, or better advantage on recovery.
  - Wind
    - Windboxes are hitboxes that deal knockback, but cause no hitstun. As a purely aesthetic conceit, windboxes will also make certain parts of a character, such as Link's cap, respond realistically to the wind. Windboxes are typically non-damaging.
  - Hitbox types have unique:
    - Color
    AND
<<<<<<< HEAD
    - Shape
=======
    - Shape
>>>>>>> d9e4d0fb11378721a8e5009ae8bcf3593df54c82
