local bpLib = StaticFindObject("/Script/UMG.Default__WidgetBlueprintLibrary")

local uiDebug = {}

-- dump widget tree
local panelClass = StaticFindObject("/Script/UMG.PanelWidget")
local userWidgetClass = StaticFindObject("/Script/UMG.UserWidget")

function uiDebug.dumpTree(widget, depth)
    if not widget or not widget:IsValid() then
        return
    end
    print(string.rep("  ", depth) .. widget:GetFName():ToString() .. "  [" .. widget:GetClass():GetFName():ToString() ..
              "]\n")

    -- walk walk walk
    if widget:IsA(panelClass) then
        for i = 0, widget:GetChildrenCount() - 1 do
            dumpTree(widget:GetChildAt(i), depth + 1)
        end
        -- walk walk walk
    elseif widget:IsA(userWidgetClass) then
        local t = widget.WidgetTree
        if t and t:IsValid() then
            dumpTree(t.RootWidget, depth + 1)
        end
    end
end

return uiDebug