local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")
modstxt_parser.validate_mod_entries(scraped_mods)
if DEBUG then require("cli")(scraped_mods) end

local uiInject = require("uiInject")
RegisterKeyBind(Key.F9, function()
    uiInject.injectButtonVertical("WBP_MainPage_C", "WBP_MainMenùButton_C", "BSettings"):SetPadding({Left = 0, Top = 4, Right = 0, Bottom = 4})
end)
