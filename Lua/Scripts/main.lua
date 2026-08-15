local uiInject = require("uiInject")

RegisterKeyBind(Key.F9, function()
    uiInject.injectButtonVertical("WBP_MainPage_C", "WBP_MainMenùButton_C", "BSettings"):SetPadding({Left = 0, Top = 4, Right = 0, Bottom = 4})
end)