-- this file serves to inject the "Mods" button into the main menu and pause menu.
-- it probably will never need to be touched again.
-- to change button function go to line 221

local bpLib = StaticFindObject("/Script/UMG.Default__WidgetBlueprintLibrary")

local BP = require("blueprintBridge")

local uiInject = {}

function uiInject.injectButtonVertical(menu, buttonName, insertIndex)
    if not menu or not menu:IsValid() then
        print("[ModMenu] [uiInject] [injectButtonVertical] provided menu is invalid\n")
        return
    end

    -- get the selected button from the name
    local templateInstance = menu[buttonName]
    if not templateInstance or not templateInstance:IsValid() then
        print("[ModMenu] [uiInject] " .. buttonName .. " not found in " .. menu:GetFullName() .. "\n")
        return
    end

    -- get the actual template class from the instance
    local template = templateInstance:GetClass()

    -- now get parent of the settings button
    local verticalBox = templateInstance:GetParent()
    if not verticalBox or not verticalBox:IsValid() then
        print("[ModMenu] [uiInject] [injectButtonVertical] menu does not contain a VerticalBox\n")
        return
    end

    -- get the player controller
    local playerController = menu:GetOwningPlayer()
    if not playerController or not playerController:IsValid() then
        print("[ModMenu] [uiInject] [injectButtonVertical] unable to find a PlayerController\n")
        return
    end

    -- now clone the template into a new button
    local newButton = bpLib:Create(verticalBox, template, playerController)

    -- make visible otherwise it will be set to collapsed
    newButton:SetVisibility(0)

    -- then add the new button into the list
    local slot = verticalBox:AddChildToVerticalBox(newButton)
    if not slot then
        print("[ModMenu] [uiInject] [injectButtonVertical] unable inject new button into the menu\n")
        return
    end

    if not insertIndex then
        -- just append at the end
        return slot
    end

    -- save all children along with their slot properties since ClearChildren destroys them
    local children = {}
    local childCount = verticalBox:GetChildrenCount()

    for i = 0, childCount - 1 do
        local child = verticalBox:GetChildAt(i)
        local s = child.Slot
        children[#children + 1] = {
            widget = child,
            padding = {
                Left = s.Padding.Left,
                Top = s.Padding.Top,
                Right = s.Padding.Right,
                Bottom = s.Padding.Bottom
            },
            hAlign = s.HorizontalAlignment,
            vAlign = s.VerticalAlignment,
            rule = s.Size.SizeRule,
            value = s.Size.Value
        }
    end

    -- remove the new button from the end
    local moved = table.remove(children)

    -- insert it into the children index
    if insertIndex > #children + 1 then
        insertIndex = #children + 1
    end
    table.insert(children, insertIndex, moved)

    -- remove all children from the vertical box
    verticalBox:ClearChildren()

    -- add all children back in the correct order and restore their slots
    local newSlot
    for i, entry in ipairs(children) do
        local s = verticalBox:AddChildToVerticalBox(entry.widget)
        s:SetPadding(entry.padding)
        s:SetHorizontalAlignment(entry.hAlign)
        s:SetVerticalAlignment(entry.vAlign)
        s.Size.SizeRule = entry.rule
        s.Size.Value = entry.value
        if i == insertIndex then
            newSlot = s
        end
    end

    return newSlot, newButton
end

-- store if injected or not so it doesn't create a new button every time
local injected = {}
-- track the clones that were created so the click hook can filter to the right one
local myButtons = {}

-- register hook on pause menu creation
local function registerHooks()
    RegisterHook("/Game/Widget/PauseMenù/Pages/WBP_PauseMenùVoices.WBP_PauseMenùVoices_C:Construct", function(ctx)
        local menu = ctx:get()
        if not menu or not menu:IsValid() then
            print("[ModMenu] [uiInject] [pauseMenuHook] menu returned nil")
        end

        -- guard against creating a second button
        local id = menu:GetFullName()
        local button = injected[id]

        if not button or not button:IsValid() then
            local slot
            slot, button = uiInject.injectButtonVertical(menu, "BSettings", 8)

            if not slot or not button then
                print("[ModMenu] [uiInject] [pauseMenuHook] injection failed\n")
                return
            end

            -- add padding at bottom so it doesn't look weird
            slot:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 10 })

            -- add button to injected and also to the list of buttons for clicking
            injected[id] = button
            myButtons[button:GetFullName()] = true
        end

        -- need to use GetChildAt for everything because the letter ù creates errors
        local root = button.WidgetTree.RootWidget
        local uButton = root:GetChildAt(0)
        local vbox = uButton:GetChildAt(0)
        local title = vbox:GetChildAt(0)

        -- set text every time or it will revert to default. no idea why though
        title:SetText(FText("Mods"))
    end)

    -- register hook on main menu creation
    RegisterHook("/Game/Widget/MainMenù/Componenets/Pages/WBP_MainPage.WBP_MainPage_C:Construct", function(ctx)
        local menu = ctx:get()
        if not menu or not menu:IsValid() then
            print("[ModMenu] [uiInject] [mainMenuHook] menu returned nil")
        end

        local id = menu:GetFullName()
        local button = injected[id]

        if not button or not button:IsValid() then
            local slot
            slot, button = uiInject.injectButtonVertical(menu, "BSettings", 7)
            if not slot or not button then
                print("[ModMenu] [uiInject] [mainMenuHook] injection failed\n")
                return
            end

            slot:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 10 })

            -- add button to injected and also to the list of buttons for clicking
            injected[id] = button
            myButtons[button:GetFullName()] = true
        end

        -- need to use GetChildAt for everything because the letter ù creates errors
        local root = button.WidgetTree.RootWidget
        local uButton = root:GetChildAt(0)
        local vbox = uButton:GetChildAt(0)
        local title = vbox:GetChildAt(0)

        -- set text every time or it will revert to default. no idea why though
        title:SetText(FText("Mods"))
    end)

    -- now for the clicking stuff

    -- register the click hook once at load off the button class itself
    local buttonCls = StaticFindObject(
        "/Game/Widget/MainMen\u{F9}/Componenets/Button/WBP_MainMen\u{F9}Button.WBP_MainMen\u{F9}Button_C")
    if not buttonCls or not buttonCls:IsValid() then
        print("[ModMenu] [uiInject] button class not loaded, click hook not registered\n")
    else
        -- the OnRelease function has to be found again because of the letter ù
        local clickFn
        buttonCls:ForEachFunction(function(fn)
            local n = fn:GetFName():ToString()
            if n:find("BndEvt", 1, true) and n:find("OnButtonReleasedEvent", 1, true) then
                clickFn = n
            end
        end)

        if not clickFn then
            print("[ModMenu] [uiInject] [clickingStuff] OnRelease function could not be found\n")
        else
            -- find the full assetpath and then register a hook to it + the OnRelease function name (I know this is bad but it works)
            local assetPath = buttonCls:GetFullName():match("%S+%s+(.+)")
            RegisterHook(assetPath .. ":" .. clickFn, function(ctx)
                local self = ctx:get()
                if not self or not self:IsValid() then
                    return
                end
                if not myButtons[self:GetFullName()] then
                    return
                end

                -- function stuff goes here (probably just call a function to enable bp menu)
                BP.ModMenu_ToggleVisibility()
            end)
        end
    end
end

-- wait to register the hooks because otherwise it will try to register a hook that doesn't exist and throw
local done = false
RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    if done then
        return
    end
    done = true
    registerHooks()
end)

return uiInject
