local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

local terminalApps = {
    ["Alacritty"] = true,
    ["kitty"] = true,
    ["iTerm"] = true,
    ["iTerm2"] = true,
    ["WezTerm"] = true,
    ["Ghostty"] = true,
    ["Terminal"] = true,
}

-- Commands
hs.hotkey.bind(super, "h", hs.toggleConsole)
hs.hotkey.bind(super, "q", nil, function() hs.eventtap.keyStroke({"cmd"}, "q") end)
hs.hotkey.bind(super, "l", nil, function() hs.eventtap.keyStroke({"ctrl", "cmd"}, "q") end)

-- copy / paste / select all / undo / find / save
local ctrlA = hs.hotkey.bind({"ctrl"}, "a", nil, function() hs.eventtap.keyStroke({"cmd"}, "a") end)
local ctrlX = hs.hotkey.bind({"ctrl"}, "x", nil, function() hs.eventtap.keyStroke({"cmd"}, "x") end)
local ctrlV = hs.hotkey.bind({"ctrl"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)
local ctrlZ = hs.hotkey.bind({"ctrl"}, "z", nil, function() hs.eventtap.keyStroke({"cmd"}, "z") end)
local ctrlF = hs.hotkey.bind({"ctrl"}, "f", nil, function() hs.eventtap.keyStroke({"cmd"}, "f") end)
local ctrlS = hs.hotkey.bind({"ctrl"}, "s", nil, function() hs.eventtap.keyStroke({"cmd"}, "s") end)
local ctrlC = hs.hotkey.bind({"ctrl"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
hs.hotkey.bind({"ctrl"}, "return", nil, function() hs.eventtap.keyStroke({"cmd"}, "return") end)
hs.hotkey.bind(nil, "f13", nil, function() hs.eventtap.keyStroke({"ctrl", "cmd", "shift"}, "4") end)

-- terminal-only: Ctrl+Shift+C/V for copy/paste (linux terminal convention)
local shiftCopy = hs.hotkey.new({"ctrl", "shift"}, "c", nil, function() hs.eventtap.keyStroke({"cmd"}, "c") end)
local shiftPaste = hs.hotkey.new({"ctrl", "shift"}, "v", nil, function() hs.eventtap.keyStroke({"cmd"}, "v") end)

-- bindings to disable in terminal apps (where ctrl+key has shell meaning)
local guiBindings = { ctrlA, ctrlX, ctrlV, ctrlZ, ctrlF, ctrlC }
-- bindings to enable in terminal apps
local termBindings = { shiftCopy, shiftPaste }

local function enableGuiMode()
    for _, hk in ipairs(guiBindings) do hk:enable() end
    for _, hk in ipairs(termBindings) do hk:disable() end
end

local function enableTermMode()
    for _, hk in ipairs(guiBindings) do hk:disable() end
    for _, hk in ipairs(termBindings) do hk:enable() end
end

function applicationWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        if terminalApps[appName] then
            enableTermMode()
        else
            enableGuiMode()
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Cloudflare WARP toggle (Caps+W)
hs.hotkey.bind(super, "W", function()
    local output, status = hs.execute("/usr/local/bin/warp-cli status 2>/dev/null")
    if output and output:find("Connected") then
        hs.execute("/usr/local/bin/warp-cli disconnect")
        hs.alert.show("WARP Disconnected")
    else
        hs.execute("/usr/local/bin/warp-cli connect")
        hs.alert.show("WARP Connected")
    end
end)