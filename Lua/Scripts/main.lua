local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")
local uiInject = require("uiInject")

RegisterKeyBind(Key.F9, function()
    uiInject.injectButtonVertical("WBP_MainPage_C", "WBP_MainMenùButton_C", "BSettings"):SetPadding({Left = 0, Top = 4, Right = 0, Bottom = 4})
end)

--? Checks if there is a mod folder for each entry in mods.txt
--? Checks if there is an entry for each folder in the Mods directory, and if not, we add the entry defaulting to disabled
modstxt_parser.validate_mod_entries(scraped_mods)
