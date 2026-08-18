local BP = {}

-- register a custom event for each widget so we can get it as a reference
local canvas
RegisterCustomEvent("ModMenuCanvasSpawn", function(self)
    local widget = self:get()
    if widget and widget:IsValid() then
        canvas = widget
        print("[ModMenu] Canvas registered\n")
    end
end)

-- self explanatory
function BP.Canvas_ToggleVisibility()
    ExecuteInGameThread(function()
        canvas:ToggleVisibility()
    end)
end

RegisterKeyBind(Key.O, function()
    BP.Canvas_ToggleVisibility()
end)

return BP

