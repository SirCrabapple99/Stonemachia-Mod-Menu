local bpLib = StaticFindObject("/Script/UMG.Default__WidgetBlueprintLibrary")

local uiInject = {}

function uiInject.injectButtonVertical(ownerClassName, menuName, buttonName)
    -- find all the buttons in the menu chosen
    local all = FindAllOf(menuName)
    if not all then
        print("[ModMenu] [uiInject] [injectButtonVertical] menu with name of " .. menuName .. " not found")
        return
    end

    -- find the selected button
    local templateInstance = nil
    for _, widget in ipairs(all) do
        if widget:GetFName():ToString() == buttonName then
            local outer = widget:GetOuter()
            if outer then
                local owner = outer:GetOuter()
                if owner and owner:IsValid() and owner:GetClass():GetFName():ToString() == ownerClassName then
                    templateInstance = widget
                    break
                end
            end
        end
    end

    if not templateInstance then
        print("[ModMenu] [uiInject] [injectButtonVertical] button with name of " .. buttonName .. " not found")
        return
    end

    -- get the actual template class from the instance
    local template = templateInstance:GetClass()

    -- now get parent of the settings button
    local verticalBox = templateInstance:GetParent()
    if not verticalBox or not verticalBox:IsValid() then
        print("[ModMenu] [uiInject] [injectButtonVertical] menu does not contain a VerticalBox")
        return
    end
    -- get the player controller
    local playerController = FindFirstOf("PlayerController")
    if not playerController or not playerController:IsValid() then
        print("[ModMenu] [uiInject] [injectButtonVertical] unable to find a PlayerController")
        return
    end

    -- now clone the template into a new button
    local newButton = bpLib:Create(verticalBox, template, playerController)

    -- make visible otherwise it will be set to collapsed
    newButton:SetVisibility(0)

    -- then add the new button into the list
    local slot = verticalBox:AddChildToVerticalBox(newButton)
    if not slot then
        print("[ModMenu] [uiInject] [injectButtonVertical] unable inject new button into the menu")
        return
    end

    return slot
end

return uiInject
