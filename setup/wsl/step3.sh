# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

########## Ask the user for hostname - which drives configuration
options=("nixos" "ares" "work")
echo -e "It looks like you're setting up WSL2 for the first time. There are 3 pre-configured hosts for WSL2."
echo " "
echo "The options are:"
echo -e "  ${BBlue}- \"nixos\"    ${Cyan} -- Default with no secrets or public keys applied." 
echo -e "  ${BBlue}- \"ares\" 	  ${Cyan} -- Designed for mixed-use. Includes personal keys, but no system access keys." 
echo " "
echo -e "${Color_Off}"
select opt in "${options[@]}"
do
    case $opt in
        "nixos"|"ares"|"work")
            echo "Using $opt config. ";break;;
        *) echo -e "${Red}Invalid option. Please select a valid option or press crtl-c to quit.";;
    esac
done
echo -e "${Color_Off}"
sudo nixos-rebuild switch --flake ../../#$opt