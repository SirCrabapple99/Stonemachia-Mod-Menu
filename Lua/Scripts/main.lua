local DEBUG = true

local scraped_mods = require("mods scraper")

for _, mod in ipairs(scraped_mods) do
    print("Mod name: " .. mod.name)
    print("Mod path: " .. mod.path)
    print("Has enabled.txt: " .. string.format("%s", mod.has_enabledtxt))
end
