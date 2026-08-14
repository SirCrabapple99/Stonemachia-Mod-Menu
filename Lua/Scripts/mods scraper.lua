local DEBUG = false

local function find_mods()
    local mods_array = {}
    local handle = io.popen("dir" .. "..\\Win64\\ue4ss\\Mods" .. "/b")
    if DEBUG then print("[Stonemachia Mod Menu] Scraping Mods directory...") end
    for file_or_folder in handle:lines() do
        if DEBUG then print("[Stonemachia Mod Menu] Found " .. file_or_folder .. " in Mods directory") end
        --? Is this a mod folder or a file in the Mods directory? We only want mod folders
        local file, _ = io.open("..\\Win64\\ue4ss\\Mods\\" .. file_or_folder, "r")
        local enabledtxt, _ = io.open("..\\Win64\\ue4ss\\Mods\\" .. file_or_folder .. "\\enabled.txt", "r")
        if not file then
            local mod_info = {
                name = file_or_folder,
                has_enabledtxt = not not enabledtxt,
                path = "..\\Win64\\ue4ss\\Mods\\" .. file_or_folder
            }
            table.insert(mods_array, mod_info)
        else file:close() end
    end
    if DEBUG then
        print("[Stonemachia Mod Menu] Printing found mods...")
        for _, mod in ipairs(mods_array) do print("[Stonemachia Mod Menu] Found mod: " .. mod) end
    end
    return mods_array
end

return find_mods()