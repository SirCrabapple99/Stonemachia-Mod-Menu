-- this file serves 2 purposes, first being to bridge lua and blueprints by  
-- registering their "Spawn" events and grabbing their reference, and second
-- to hold functions that are called by both lua AND blueprints. fnctions 
-- called by blueprints should be named as (widget name)_(function name).
--
-- REFERENCE GRABBING
local ModMenu
local PC
local MainPage

local BP = {MainPage, PC, ModMenu}

RegisterCustomEvent("ModMenuSpawn", function(self)
    local widget = self:get()
    if widget and widget:IsValid() then
        ModMenu = widget
        print("[ModMenu] ModMenu registered\n")
    end

    local p = FindFirstOf("PC_PlayerControllerMaster_C")
    if p and p:IsValid() then
        PC = p
    end

    local m = FindFirstOf("WBP_MainPage_C")
    if m and m:IsValid() then
        MainPage = m
    end
end)

-- Mod_Menu functions
function BP.ModMenu_ToggleVisibility()
    ExecuteInGameThread(function()
        ModMenu:ToggleVisibility()

        if MainPage and MainPage:IsValid() then
            MainPage:SetVisibility(0)
        end
    end)
end

-- store the focus state of the mod menu and the previously focused menu
local isFocused = false
local prevRef = nil

function BP.ModMenu_FocusInput()
    ExecuteInGameThread(function()
        -- if the mod menu is already focused don't override the previously
        -- opened widget, otherwise the game will softlock
        if isFocused then
            return
        end
        prevRef = PC.CurrentOpenedWidgetRef
        PC:OnWidgetOpened(ModMenu, false, false)
        isFocused = true

        if MainPage and MainPage:IsValid() then
            MainPage:SetVisibility(3)
        end
    end)
end

function BP.ModMenu_UnfocusInput()
    ExecuteInGameThread(function()
        -- same thing here but in reverse
        if not isFocused then
            return
        end
        if prevRef and prevRef:IsValid() then
            PC:OnWidgetOpened(prevRef, false, false)
        else
            PC:OnWidgedClosed()
        end
        isFocused = false
    end)
end

-- TEMP DEBUG KEYBINDS
local function refName()
    local r = PC.CurrentOpenedWidgetRef
    if r and r:IsValid() then
        return r:GetFullName()
    end
    return "nil"
end

RegisterKeyBind(Key.O, function()
    BP.ModMenu_ToggleVisibility()
end)

RegisterKeyBind(Key.R, function()
    BP.ModMenu_FocusInput()
end)

RegisterKeyBind(Key.T, function()
    BP.ModMenu_UnfocusInput()
end)

RegisterKeyBind(Key.Y, function()
    print(refName())
end)

return BP

