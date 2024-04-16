local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}


-- Commands
hs.hotkey.bind(super, "q", nil, function() hs.eventtap.keyStroke({"cmd"}, "q") end)
-- copy / paste / select all / select none / undo
hs.hotkey.bind({"ctrl"}, "a", nil, function() hs.eventtap.keyStroke({"cmd"}, "a") end)
hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "x", nil, function() hs.eventtap.keyStroke({"cmd"}, "x") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "z", nil, function() hs.eventtap.keyStroke({"cmd"}, "z") end)
hs.hotkey.bind({"ctrl"}, "f", nil, function() hs.eventtap.keyStroke({"cmd"}, "f") end)
hs.hotkey.bind({"ctrl"}, "s", nil, function() hs.eventtap.keyStroke({"cmd"}, "s") end)
hs.hotkey.bind({"ctrl"}, "return", nil, function() hs.eventtap.keyStroke({"cmd"}, "return") end)
hs.hotkey.bind(nil, "f13", nil, function() hs.eventtap.keyStroke({"ctrl, cmd, shift"}, "4") end)