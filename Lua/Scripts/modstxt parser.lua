local DEBUG = false

local modstxt_parser = {}

local modstxt_path = "..\\Win64\\ue4ss\\Mods\\mods.txt"

--* Central function to write to mods.txt
--* Attempts to create a backup first and only commits to writing the original file if the backup is successful
--* Parameter lines: The array of data to write to mods.txt
local function write_to_modstxt(lines)
    --? Back up mods.txt
    local success, _ = pcall(function()
        local original_modstxt, err = io.open(modstxt_path, "rb")
        local backup_modstxt, err = io.open("..\\Win64\\ue4ss\\Mods\\mods.txt.backup", "wb")
        local content = original_modstxt:read("*a")
        backup_modstxt:write(content)
        original_modstxt:close()
        backup_modstxt:close()
    end)
    --? Do not modify the original mods.txt if we fail to back it up first
    if not success then
        if DEBUG then print("[Stonemachia Mod Menu] Failed to back up mods.txt, original mods.txt file will not be modified") end
        return
    end
    local write_file = io.open(modstxt_path, "w")
    if write_file then
        write_file:write(table.concat(lines, "\n"))
        write_file:close()
    end
end

--* Enables or disables the specified mod, then writes the changes to mods.txt
--* Parameter mod_name: The name of the mod we want to enable/disable
--* Parameter enabled: Whether to enable or disable the specified mod
function modstxt_parser.toggle_mod(mod_name, enabled)
    if enabled then RestartMod(mod_name) else UninstallMod(mod_name) end
    local file = io.open(modstxt_path, "r")
    if not file then return end
    local lines = {}
    for line in file:lines() do
        if line:find(mod_name .. "%s*:") then
            table.insert(lines, mod_name .. " : " .. (enabled and "1" or "0"))
        else
            table.insert(lines, line)
        end
    end
    file:close()
    write_to_modstxt(lines)
end

--* Validates the mods.txt file to ensure consistency across its entries and the mod folders
--* Will comment out entries from mods.txt if there is no associated mod folder
--* Will create new entries if there is none for any mod folder, and default them to disabled
--* Parameter scraped_mods: The array of mods from the Mods directory, produced by the mods scraper
function modstxt_parser.validate_mod_entries(scraped_mods)
    --? Document all the mod names in a map
    local scraped_mods_names = {}
    for _, mod in ipairs(scraped_mods) do
        scraped_mods_names[mod.name] = false
    end
    local file = io.open(modstxt_path, "r")
    if not file then return end
    local lines = {}
    for line in file:lines() do
        if #line > 0 then --? Ignore empty lines
            local parsed_line = {}
            for match in string.gmatch(line, "[^%s:%s]+") do table.insert(parsed_line, match) end
            if parsed_line[1] == ";" then
                if DEBUG then print("[Stonemachia Mod Menu] This entry is a comment, skipping...") end
            else
                if scraped_mods_names[parsed_line[1]] == nil then
                    if DEBUG then print("[Stonemachia Mod Menu] Could not find mod folder for " .. parsed_line[1] .. ", this entry will be commented out") end
                    line = "; " .. line
                else scraped_mods_names[parsed_line[1]] = true end
            end
        end
        table.insert(lines, line)
    end
    file:close()
    for key, value in pairs(scraped_mods_names) do
        if not value then
            if DEBUG then print("[Stonemachia Mod Menu] No specification found in mods.txt for " .. key .. ", defaulting to disabled") end
            table.insert(lines, key .. " : " .. "0")
        end
    end
    write_to_modstxt(lines)
end

return modstxt_parser
