local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")

modstxt_parser.validate_mod_entries(scraped_mods)
