local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")
modstxt_parser.validate_mod_entries(scraped_mods)
if DEBUG then require("cli")(scraped_mods) end

local uiInject = require("uiInject")
RegisterKeyBind(Key.F9, function()
    local slot = uiInject.injectButtonVertical("WBP_PauseMenùVoices_C", "WBP_MainMenùButton_C", "BSettings", 1)
    slot:SetPadding({
        Left = 0,
        Top = 4,
        Right = 0,
        Bottom = 4
    })
end)
