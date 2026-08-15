local modstxt_parser = {}

local modstxt_path = "..\\Win64\\ue4ss\\Mods\\mods.txt"

function modstxt_parser.toggle_mod(mod_name, enabled)
    local file = io.open(modstxt_path, "r")
    if not file then return end
    local lines = {}
    for line in file:lines() do
        if line:find(mod_name .. "%s*:") then
            table.insert(lines, mod_name .. " : " .. enabled and "1" or "0")
        else
            table.insert(lines, line)
        end
    end
    file:close()

    local write_file = io.open(modstxt_path, "w")
    if write_file then
        write_file:write(table.concat(lines, "\n"))
        write_file:close()
    end
end
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
            if parsed_line[1] == ";" then print("This entry is a comment, skipping...") else
                if scraped_mods_names[parsed_line[1]] == nil then
                    print("[Stonemachia Mod Menu] Could not find mod folder for " .. parsed_line[1] .. ", this entry will be commented out")
                    line = "; " .. line
                else scraped_mods_names[parsed_line[1]] = true end
            end
        end
        table.insert(lines, line)
    end
    file:close()

    for key, value in pairs(scraped_mods_names) do
        if not value then
            print("[Stonemachia Mod Menu] No specification found in mods.txt for " .. key .. ", defaulting to disabled")
            table.insert(lines, key .. " : " .. "0")
        end
    end
    local write_file = io.open(modstxt_path, "w")
    if write_file then
        write_file:write(table.concat(lines, "\n"))
        write_file:close()
    end
end

return modstxt_parser

--todo: backup mods.txt after each write
--todo: reload mods after changing them etc etc look into how to do that