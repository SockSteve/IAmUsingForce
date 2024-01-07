# IAmUsingForce
 
Folders:

    Assets: This folder contains all the assets like models, textures, animations, and sounds. Each type of asset is further categorized into sub-folders.

    Scenes: It includes individual scenes for various aspects of the game. Each major category like Levels, Characters, UI, and Weapons has its own folder. Levels can be further divided into individual subfolders for each level.

    Scripts: Scripts are organized mirroring the scene structure. For instance, scripts related to the Player are under Scripts/Characters/Player/. This makes it easier to find the scripts associated with specific scenes or game elements.

    Shaders and Materials: For custom shaders and materials used in your game.

    Addons: This would include any plugins or external tools you are using within your Godot project.

Why store scripts and scenes seperately?

Placing scripts in the same folder as their corresponding scenes can be a beneficial approach, particularly for smaller projects or when there's a strong one-to-one relationship between scripts and scenes. This method can offer several advantages:

    Ease of Navigation: It's straightforward to find the script associated with a particular scene, as they are located in the same folder.

    Clarity: There's a clear, direct link between the scene and its script, reducing confusion about which scripts affect which scenes.

    Simplicity: For smaller projects or those with a less complex structure, this approach can keep the folder hierarchy simpler and more manageable.

However, there are also scenarios where separating scripts into their own folder might be preferable, especially for larger projects:

    Modularity: When scripts are shared or used by multiple scenes, having a separate script folder can emphasize reusability and modularity.

    Complex Projects: In larger projects with many scripts, a dedicated script folder can help manage complexity, especially when scripts start to have multiple dependencies and are not exclusively tied to specific scenes.