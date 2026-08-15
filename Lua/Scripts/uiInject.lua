local bpLib = StaticFindObject("/Script/UMG.Default__WidgetBlueprintLibrary")

local uiInject = {}

function uiInject.injectButtonVertical(ownerClassName, menuName, buttonName, insertIndex)
    -- find all the buttons in the menu chosen
    local all = FindAllOf(menuName)
    if not all then
        print("[ModMenu] [uiInject] [injectButtonVertical] menu with name of " .. menuName .. " not found")
        return
    end

    -- find the selected button
    local templateInstance = nil
    for unused, widget in ipairs(all) do
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

    if not insertIndex then
        -- just append at the end
        return slot
    end

    -- save all children
    local children = {}
    local childCount = verticalBox:GetChildrenCount()

    for i = 0, childCount - 1 do
        children[#children + 1] = verticalBox:GetChildAt(i)
    end
    -- remove the new button from the end
    table.remove(children)

    -- insert it into the children index
    table.insert(children, insertIndex, newButton)

    -- remove all children from the vertical box
    verticalBox:ClearChildren()
    -- add all children back in the correct order
    for unused, widget in ipairs(children) do
        verticalBox:AddChildToVerticalBox(widget)
    end

    return slot
end

return uiInject
