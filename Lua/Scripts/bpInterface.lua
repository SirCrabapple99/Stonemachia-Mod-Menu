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

-- store the focus state of the mod menu
local isFocused = false

function BP.ModMenu_FocusInput()
    ExecuteInGameThread(function()
        -- if the mod menu is already focused don't override the previously opened widget otherwise the game will softlock
        if isFocused then return end
        prevRef = PC.CurrentOpenedWidgetRef
        PC:OnWidgetOpened(ModMenu, false, false)
        isFocused = true
    end)
end

function BP.ModMenu_UnfocusInput()
    ExecuteInGameThread(function()
        -- same thing here but in reverse
        if not isFocused then return end
        if prevRef and prevRef:IsValid() then
            PC:OnWidgetOpened(prevRef, false, false)
        else
            PC:OnWidgedClosed()
        end
        isFocused = false
    end)
end

local function refName()
    local r = PC.CurrentOpenedWidgetRef
    if r and r:IsValid() then return r:GetFullName() end
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

