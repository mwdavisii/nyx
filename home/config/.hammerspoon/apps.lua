local super = {"ctrl", "alt", "cmd"}
local superShift = {"ctrl", "alt", "cmd", "lshift"}

--- start quick open applications 
function open_app(name)
    return function()
      hs.application.launchOrFocus(name)
      if name == 'Finder' then
        hs.appfinder.appFromName(name):activate()
      end
    end
  end
  
-- Apps
hs.hotkey.bind(super, "C",        open_app("Visual Studio Code"))
hs.hotkey.bind(super, "B",        open_app("Google Chrome"))
hs.hotkey.bind(super, "O",        open_app("Microsoft Outlook"))
hs.hotkey.bind(super, "T",        open_app("Microsoft Teams (work or school)"))
hs.hotkey.bind(super, "return",   open_app("Alacritty"))
hs.hotkey.bind(super, "K",        open_app("Kitty"))
hs.hotkey.bind(super, "F",        open_app("Finder"))
hs.hotkey.bind(super, "space",    open_app("launchpad"))