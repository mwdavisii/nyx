local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}


-- Commands
hs.hotkey.bind(super, "h", hs.toggleConsole)
hs.hotkey.bind(super, "q", nil, function() hs.eventtap.keyStroke({"cmd"}, "q") end)
hs.hotkey.bind(super, "l", nil, function() hs.eventtap.keyStroke({"ctrl, cmd"}, "q") end)

-- copy / paste / select all / select none / undo
hs.hotkey.bind({"ctrl"}, "a", nil, function() hs.eventtap.keyStroke({"cmd"}, "a") end)
hs.hotkey.bind({"ctrl"}, "x", nil, function() hs.eventtap.keyStroke({"cmd"}, "x") end)
hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
hs.hotkey.bind({"ctrl"}, "z", nil, function() hs.eventtap.keyStroke({"cmd"}, "z") end)
hs.hotkey.bind({"ctrl"}, "f", nil, function() hs.eventtap.keyStroke({"cmd"}, "f") end)
hs.hotkey.bind({"ctrl"}, "s", nil, function() hs.eventtap.keyStroke({"cmd"}, "s") end)
hs.hotkey.bind({"ctrl"}, "return", nil, function() hs.eventtap.keyStroke({"cmd"}, "return") end)
hs.hotkey.bind(nil, "f13", nil, function() hs.eventtap.keyStroke({"ctrl, cmd, shift"}, "4") end)


-- these are named only so0 that we can enable and disable in terminal apps
local windowsCopy = hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
local shiftCopy = hs.hotkey.bind({"ctrl", "lshift"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
local shiftPaste = hs.hotkey.bind({"ctrl", "lshift"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
shiftCopy:disable()
shiftPaste:disable()

function applicationWatcher(appName, eventType, appObject)
    if (appName == "Alacritty" or appName == "kitty" or appName == "iTerm" or appName == "WezTerm") then
        windowsCopy:disable()
        shiftCopy:enable()
        shiftPaste:enable()
    end
    if (eventType == hs.application.watcher.deactivated) then
        if (appName == "Alacritty" or appName == "kitty" or appName == "iTerm" or appName == "WezTerm") then
            shiftCopy:disable()
            shiftPaste:disable()
            windowsCopy:enable()
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)

appWatcher:start()