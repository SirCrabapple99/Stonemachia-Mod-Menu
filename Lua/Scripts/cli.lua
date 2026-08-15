local modstxt_parser = require("modstxt parser")

--* Simple debug CLI to verify backend functionality
--* Command DisplayModMenu: Displays the scraped mods formatted as follows:
--*    Mod name: The name of the mod, e.g. "DisableCameraSmoothing"
--*    Mod status: The status of the mod, and whether it has an enabled.txt file, e.g. "ENABLED", "DISABLED, has enabled.txt"
--*    Mod type: The type of the mod, e.g. "UE4SS system mod", "user mod"
--* Usage: `DisplayModMenu`
--* Command ToggleMod: Toggles a mod on or off, if no specified status is provided it will flip the mod's current status
--* If the mod is invalid (e.g. does not exist) it will output "Mod INVALID_MOD set to: DISABLED", but it doesnt actually do anything
--* Usage: `ToggleMod [MANDATORY: MOD_NAME] [OPTIONAL: true/false]`
local function init_cli(mods)
    print("[Stonemachia Mod Menu] Initializing Mod Menu CLI...")
    RegisterConsoleCommandHandler("DisplayModMenu", function(FullCommand, Parameters, OutputDevice)
        for _, mod in ipairs(mods) do
            OutputDevice:Log("\nMod name: " .. mod.name)
            OutputDevice:Log("Mod status: " .. (modstxt_parser.is_mod_enabled(mod.name) and "ENABLED" or "DISABLED") .. (mod.has_enabledtxt and ", has enabled.txt" or ""))
            OutputDevice:Log("Mod type: " .. (mod.system_mod and "UE4SS system mod" or "user mod"))
        end
        return true
    end)
    RegisterConsoleCommandHandler("ToggleMod", function(FullCommand, Parameters, OutputDevice)
        if #Parameters == 0 then OutputDevice:Log("You must provide the name of a mod to toggle") else
            --? If there is no specified status, flip the mod's status, otherwise set the specified status
            modstxt_parser.toggle_mod(Parameters[1], (#Parameters == 1 and not modstxt_parser.is_mod_enabled(Parameters[1]) or Parameters[2] == "true"))
            OutputDevice:Log("Mod " .. Parameters[1] .. " set to: " .. (modstxt_parser.is_mod_enabled(Parameters[1]) and "ENABLED" or "DISABLED") .. "\nPress [CTRL+R] to reload mods.txt and apply the changes")
        end
        return true
    end)
end

return init_cli