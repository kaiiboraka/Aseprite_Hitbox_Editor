# Aseprite Hitbox Editor
A plugin/script for Aseprite for easily creating usable hitbox data for pixel art animations. 

## Toolbar Functionality

- add
  - Create New Hitbox in its own Layer
- remove
  - Delete a selected Hitbox Layer
- edit
  - Modify existing hitbox data
- hide/show
  - toggle visibility of selected hitbox layer
- settings
  - export
    - create simple JSON representation of hitbox data easily mappable to animation frames by frame number
  - import
    - load in a JSON file with hitbox data and create a corresponding Hitbox_Data group with its layers

## Hitbox Data
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

