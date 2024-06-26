#
# Prompt config
#
export PROMPT_DIR_COLOR=$CL_CYAN
export PROMPT_MODE=left
export PROMPT_NO_INFO_LINE=true

# Stop dotnet from collecting telemetry. FK OFF MICROSOFT!! (╯°□°）╯︵ ┻━┻
export DOTNET_CLI_TELEMETRY_OPTOUT=1

if [ command -v wal >/dev/null 2>&1 ]; then
    wal -R -q
fi