local uiInject = require("uiInject")

RegisterKeyBind(Key.F9, function()
    local slot = uiInject.injectButtonVertical("WBP_PauseMenùVoices_C", "WBP_MainMenùButton_C", "BSettings", 1)
    slot:SetPadding({
        Left = 0,
        Top = 4,
        Right = 0,
        Bottom = 4
    })
end)
