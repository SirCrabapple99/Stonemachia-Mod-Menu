-- this file serves 2 purposes, first being to bridge lua and blueprints by  
-- registering their "Spawn" events and grabbing their reference, and second
-- to hold functions that are called by both lua AND blueprints. functions 
-- called by blueprints should be named as (widget name)_(function name).
--
-- REFERENCE GRABBING
local ModMenu = nil
local PC = nil
local MainPage = nil
local PausePage = nil

local BP = {}

-- get ref to the ModMenu widget and also find the pc and menu pages
RegisterCustomEvent("ModMenuSpawn", function(self)
    local widget = self:get()
    if widget and widget:IsValid() then
        ModMenu = widget
        print("[ModMenu] ModMenu registered\n")
    end

    -- find pc
    local p = FindFirstOf("PC_PlayerControllerMaster_C")
    if p and p:IsValid() then
        PC = p
    end

    -- find MainPage (main menu)
    local m = FindFirstOf("WBP_MainPage_C")
    if m and m:IsValid() then
        MainPage = m
        print("[ModMenu] MainPage registered\n")
    end

    -- find PauseMenuVoices (pause menu)
    local v = FindFirstOf("WBP_PauseMenùVoices_C")
    if v and v:IsValid() then
        PausePage = v
        print("[ModMenu] PausePage registered\n")
    end
end)

-- Mod_Menu functions

-- self explanatory
function BP.ModMenu_ToggleVisibility()
    ExecuteInGameThread(function()
        ModMenu:ToggleVisibility()

        -- hide the main/pause page so that it doesn't steal navigation input
        if MainPage and MainPage:IsValid() then
            MainPage:SetVisibility(0)
        end

        if PausePage and PausePage:IsValid() then
            PausePage:SetVisibility(0)
        end
    end)
end

-- vars store the focus state of the mod menu and the previously focused menu
local isFocused = false
local prevRef = nil

-- focus the non navigation inputs onto the ModMenu
function BP.ModMenu_FocusInput()
    ExecuteInGameThread(function()
        -- if the mod menu is already focused don't override the previously
        -- opened widget, otherwise the game will softlock
        if isFocused then
            return
        end
        prevRef = PC.CurrentOpenedWidgetRef
        -- this gives focus to the referenced widget. weird function naming
        PC:OnWidgetOpened(ModMenu, false, false)
        isFocused = true

        -- restore original page state (they start on vis 4 in game)
        if MainPage and MainPage:IsValid() then
            MainPage:SetVisibility(4)
        end

        if PausePage and PausePage:IsValid() then
            PausePage:SetVisibility(4)
        end
    end)
end

-- restore input focus to the widget stored as prevRef
function BP.ModMenu_UnfocusInput()
    ExecuteInGameThread(function()
        -- same softlock protection but in reverse
        if not isFocused then
            return
        end
        if prevRef and prevRef:IsValid() then
            -- focus the prevRef
            PC:OnWidgetOpened(prevRef, false, false)

            -- this selects the top button of the menu so navigation can work
            prevRef["ResetFirstFocus"](prevRef)
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

RegisterCustomEvent("UpTest", function(self)
    print("[ModMenu] Up Navigation Success")
end)

RegisterCustomEvent("CustomEvent", function(self)
    print("[ModMenu] Button B Pressed")
end)

return BP

