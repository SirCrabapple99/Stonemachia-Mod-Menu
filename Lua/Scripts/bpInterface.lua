local BP = {}

-- register a custom event for each widget so we can have it as a reference
local ModMenu
local PC
RegisterCustomEvent("ModMenuSpawn", function(self)
    local widget = self:get()
    if widget and widget:IsValid() then
        ModMenu = widget
        print("[ModMenu] ModMenu registered\n")
    end

    local pcMaster = FindFirstOf("PC_PlayerControllerMaster_C")
    if pcMaster and pcMaster:IsValid() then
        PC = pcMaster
    end
end)

local vertbox
RegisterCustomEvent("ModMenuVertBoxSpawn", function(self)
    local widget = self:get()
    if widget and widget:IsValid() then
        vertbox = widget
        print("[ModMenu] VertBox registered\n")
    end
end)

-- self explanatory
function BP.ModMenu_ToggleVisibility()
    ExecuteInGameThread(function()
        ModMenu:ToggleVisibility()
    end)
end

function BP.ModMenu_FocusInput()
    ExecuteInGameThread(function()
        PC:OnWidgetOpened(ModMenu, false, false)
    end)
end

function BP.ModMenu_UnfocusInput()
    ExecuteInGameThread(function()
        PC:OnWidgedClosed()
    end)
end

RegisterKeyBind(Key.O, function()
    BP.ModMenu_ToggleVisibility()
end)

RegisterKeyBind(Key.R, function()
    BP.ModMenu_FocusInput()
end)

RegisterKeyBind(Key.T, function() BP.ModMenu_Unfocus() end)

return BP

