local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")

--? Checks if there is a mod folder for each entry in mods.txt
--? Checks if there is an entry for each folder in the Mods directory, and if not, we add the entry defaulting to disabled
modstxt_parser.validate_mod_entries(scraped_mods)