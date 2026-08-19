-- this file serves to allow blueprints to call functions, named as
-- (widget name)_(function name).
local BP = require("blueprintBridge")

RegisterCustomEvent("ModMenu_FocusInput", function(self)
    BP.ModMenu_FocusInput()
end)

RegisterCustomEvent("ModMenu_UnfocusInput", function(self)
    BP.ModMenu_UnfocusInput()
end)
