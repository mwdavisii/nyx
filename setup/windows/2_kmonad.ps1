Set-ExecutionPolicy RemoteSigned -scope CurrentUser
scoop install stack

Copy-Item ..\..\home\config\.config\kmonad\windows\kmonad.cmd "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
# clone the KMonad repository (assuming you have `git` installed)
Remove-Item -Recurse -Force $env:USERPROFILE\.source\kmonad
git clone https://github.com/kmonad/kmonad.git $env:USERPROFILE\.source\kmonad
Set-Location $env:USERPROFILE\.source\kmonad
# compile KMonad (this will first download GHC and msys2, it takes a while)
stack build
# install kmonad.exe (copies kmonad.exe to %APPDATA%\local\bin\)
stack install