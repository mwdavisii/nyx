



;#######################################################################################
;#######################################################################################
;                                   Apps
;#######################################################################################
;#######################################################################################

; Google Chrome
#!^b::Run, chrome
; VS Code
#!^c::Run, code

;terminal
#!^Enter::Run, wt

;terminal powershell
#!^+Enter::Run, wt pwsh

;file explorer
#!^f::Run, explorer

;Outlook
#!^o::Run, "C:\Program Files\Microsoft Office\Root\Office16\OUTLOOK.EXE"

;Teams
#!^t::Run, pwsh -WindowStyle hidden -Command "Start-Process $env:LocalAppData\Microsoft\WindowsApps\ms-teams.exe"

;Google Messages
#!^m::Run, chrome.exe "https://messages.google.com/web/" " --new-window "



;#######################################################################################
;#######################################################################################
;                       Command Shortcuts / Aliases
;#######################################################################################
;#######################################################################################
;Lock Screen
#!^l::Run, rundll32.exe user32.dll,LockWorkStation

; Quit w/ Super Q
#!^q::Send !{F4}

; Launch Screen Capture to ClipBoard
PrintScreen::Send {LWin down}{SHIFT}S

; Enable Tiling
#!^k::Run, pwsh -WindowStyle hidden -Command "Enable-Tiling"
#!^+t::Run, pwsh -WindowStyle hidden -Command "Disable-Tiling"

;#######################################################################################
;#######################################################################################
;                       Virtual Desktop Navigations
;#######################################################################################
;#######################################################################################

^Right::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop ((Get-DesktopIndex) +1)"
^Left::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop ((Get-DesktopIndex) -1)"

; Virtual Desktop Mapping
#!^1::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 0"
#!^2::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 1"
#!^3::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 2"
#!^4::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 3"
#!^5::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 4"
#!^6::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 5"
#!^7::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 6"
#!^8::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 7"
#!^9::Run, pwsh -WindowStyle hidden -Command "Switch-Desktop -Desktop 8"

; Move Windows to virtual desktop
#!^+1::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 0"
#!^+2::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 1"
#!^+3::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 2"
#!^+4::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 3"
#!^+5::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 4"
#!^+6::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 5"
#!^+7::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 6"
#!^+8::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 7"
#!^+9::Run, pwsh -WindowStyle hidden -Command "Move-ActiveWindow -Desktop 8"

