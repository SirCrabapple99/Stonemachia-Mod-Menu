local DEBUG = true

local scraped_mods = require("mods scraper")
local modstxt_parser = require("modstxt parser")
modstxt_parser.validate_mod_entries(scraped_mods)
if DEBUG then require("cli")(scraped_mods) end

local uiInject = require("uiInject")

local modsMenu = require("blueprintBridge")