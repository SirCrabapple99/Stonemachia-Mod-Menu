-- this file serves to allow blueprints to call functions, denoted by
-- (widget name)_(function name). this should only contain RegisterCustomEvent's

local BP = require("blueprintBridge")

RegisterCustomEvent("ModMenu_FocusInput", function(self)
    print("focus")
    BP.ModMenu_FocusInput()
end)

RegisterCustomEvent("ModMenu_UnfocusInput", function(self)
    print("un")
    BP.ModMenu_UnfocusInput()
end)