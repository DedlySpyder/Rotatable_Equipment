# Rotatable Equipment

This is a Factorio mod that dynamically allows the player to rotate any non-square equipment by pressing the configured 
button (defaults to `R`). This mod should be compatible with most other mods.


## Mod Compatibility

The way that Factorio handles sprites means that I cannot modify the sprite images dynamically to fit with this mod in a 
clean manner. There are 3 ways this mod can handle the sprites of other mods; default, rotated sprite, rotated sprite filename

Rotated sprites from the vanilla game are rotated *90° clockwise*, this is the standard for this mod, but obviously I 
cannot stop you from doing the opposite.

This mod handles the new prototypes in the `data-updates` stage of initialization, so as long as any `data.raw` 
modifications are done in the main `data` stage they will be picked up by this mod without any need for dependencies.


### Quick How-To - Add Rotated Sprites

1. Set `Rotatable_Equipment` as an optional or hidden optional dependency
1. Call `add_sprite_file_name(...)` in the first data stage with the following values:
    * `data.raw` category name
    * `data.raw` equipment name
    * filename of the sprite to use
    * (optional) expected filename to replace
        * This can be used in case another mod replaces the filename, then this sprite will only be used if the current filename
matches this value

Example of the `battery-equipment` for the base mod:
```lua
add_sprite_file_name(
		"battery-equipment",
		"battery-equipment",
		"__Rotatable_Equipment__/graphics/rotated-battery-equipment.png",
		"__base__/graphics/equipment/battery-equipment.png"
)
```


### Default Sprite Compatibility

If new equipment are added with no additional action from the other mod then this is how the sprite is handled.

Any non-square equipment sprite will be shrunk to the largest square possible and be used like that.

Example: A 32x64 equipment (1x2 squares) have a scale of 0.5, and be shrunk down to 32x32 (1x1 squares).


### Sprite Compatibility Override

If the equipment prototype in `data.raw` has a property called `rotated_sprite` then this property is assumed to be a 
*full* sprite definition for the *normal* sprite. This definition will be used as is, so it must be a valid 
[Prototype/Sprite](https://wiki.factorio.com/Prototype/Sprite).

Example: The base game `battery-equipment` is normally 32x64, the `rotated-battery-equipment.png` is a 64x32 version of 
the base sprite. The following can be used in the main `data` stage to register it for rotation:

```lua
data.raw["battery-equipment"]["battery-mk2-equipment"].rotated_sprite = {
	filename = "__Rotatable_Equipment__/graphics/rotated-battery-mk2-equipment.png",
	height = 32,
	width = 64
}
```


### Sprite Filename Override

If the equipment prototype in `data.raw` has a property called `rotated_sprite_filename` and does *not* contain 
`rotated_sprite`, then `rotated_sprite_filename` will be used as the `filename` for the sprite. It is assumed to be the
correct size for the new equipment.

Example: The base game `battery-equipment` is normally 32x64, the `rotated-battery-equipment.png` is a 64x32 version of
the base sprite. The following can be used in the main `data` stage to register it for rotation:

```lua
data.raw["battery-equipment"]["battery-equipment"].rotated_sprite_filename = "__Rotatable_Equipment__/graphics/rotated-battery-equipment.png"
```


### Expected Base Filename

The `expected_base_filename`` property can be used to skip rotated sprite assignment.
The best example for this use case is that some mods replace the base sprites for the equipment with new ones, so the base
Rotated Equipment mod will not add it's rotated sprites in those cases (because the rotated version of an equipment would
look different from the normal one).
