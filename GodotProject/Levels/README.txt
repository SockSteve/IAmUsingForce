For Level Prototyping CSG shapes can be used.

If you want to create a more complex shape consider using a CSGCombiner3D Node as
paren for your csg shapes. It is a CSG node that allows you to combine other CSG modifiers.

For chaging the color, add a new Material. For the Albedo consider using the 
kenney_prototype_textures from the addons folder. just drag one of the png files
into the albedo texture and activate Triplanar in UV1. Then the texture will be projected correctly.
