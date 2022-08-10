#!/bin/bash

# constants
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
LYELLOW='\033[1;33m'
LPURPLE='\033[1;35m'
LCYAN='\033[1;36m'

function banner () {
        echo -e "${PURPLE}############################################"
        echo "  __  __             _      ____            "
        echo " |  \\/  |           (_)    |  _ \\           "
        echo " | \\  / | __ _  __ _ _  ___| |_) | _____  __"
        echo " | |\\/| |/ _\` |/ _\` | |/ __|  _ < / _ \\ \\/ /"
        echo " | |  | | (_| | (_| | | (__| |_) | (_) >  < "
        echo " |_|  |_|\\__,_|\\__, |_|\\___|____/ \\___/_/\\_\\"
        echo "                __/ |                       "
        echo "               |___/                        "
        echo -e "############################################${RESET}"
        echo ""
}

function authenticate () {
        read -p "Enter Username: " username
        if [ "$username" = "user1" ]; then
                read -sp "Enter Password: " password
                if [ "$password" = "letmein" ]; then
                        true
                else
                        false
                fi
        elif [ "$username" = "user2" ]; then
                read -sp "Enter Password: " password
                if [ "$password" = "pass2" ]; then
                        true
                else
                        false
                fi
        else
                false
        fi
}

function sysinfo () {
        clear
        banner
        echo "Host: $(hostname)"
        echo "User: $(whoami)"
        echo "OS: $(uname -i) $(grep '^PRETTY_NAME' /etc/os-release | gawk -F\" '{print $2}')"
        echo "IP: $(hostname -I)"

        defaultinterface=$(ip route show default | awk '/default/ {print $5}')
        read MAC < /sys/class/net/$defaultinterface/address
        echo "MAC: $MAC"

        echo "Subnet: $(ip -4 addr show dev $defaultinterface | grep '/' | awk '{print $2}' | sed -r 's:([0-9]\.)[0-9]{1,3}/:\10/:g')"

        echo "Gateway: $(route -n | grep 'UG[ \t]' | awk '{print $2}')"

        echo ""
        echo "Press Enter to return to main menu."
        read -p ""
        true
}

function datetime () {
        clear
        banner
        dateonly=$(date +"%b %m, %Y")
        timeonly=$(date +"%I:%M:%S %p")
        echo -e "${BLUE}$dateonly${RESET}"
        echo -e "${CYAN}$timeonly${RESET}"
        echo ""
        echo "Press Enter to return to main menu."
        read -p ""
        true
}

function inodefinder () {
        clear
        banner
        read -p "Enter the pathname: " pathname
        #check if path exists
        if [ -e $pathname ]; then
                echo -e "Inode number for" $pathname "is: ${RED}$(stat $pathname | grep 'Inode' | awk '{print $4}')${RESET}"
                echo "Press enter to return to main menu."
                read -p ""
                true
        else
                echo $pathname "does not exist. Press enter to return to the main menu."
                read -p ""
                true
        fi
}

function classifypath () {
        clear
        banner
        read -p "Enter the path: " pathname
        if [ -e $pathname ]; then
                case $pathname in
                        '' )
                                type="missing (empty)" ;;
                        /* )
                                if [ -f $pathname ]; then
                                        type="an Abosulte Pathname to a file"
                                else
                                        type="an Absolute Pathname to a directory"
                                fi
                                ;;
                        */ )
                                type="a Relative Pathname ending in some directory" ;;
                        */* )
                                if [ -f $pathname ]; then
                                        type="a Relative Pathname in some directory to a file"
                                else
                                        type="a Relative Pathname in some directory to a directory"
                                fi
                                ;;
                        *' '* )
                                if [ -f $pathname ]; then
                                        type="a Relative Pathname with blank(s) to a file"
                                else
                                        type="a Relative Pathname with blank(s) to a directory"
                                fi
                                ;;
                        * )
                                if [ -f $pathname ]; then
                                        type="a Relative pathname in the current directory to a file"
                                else
                                        type="a Relative pathname in the current directory to a directory"
                                fi
                                ;;
                esac
                echo "Path" $pathname "is" $type
                echo "Press enter to return to main menu."
                read -p ""
                true
        else
                echo $pathname "does not exist. Press enter to return to main menu."
                read -p ""
                true
        fi
}

function cancel () {
        echo ""
        echo "Operation cancelled. Press Enter to exit."
        read -sp ""
}

function ipscan () {
        declare -a aliveList=()
        numAlive=0
        CANCEL=
        trap 'CANCEL=1' SIGINT # set cancel to 1 on Ctrl-C (SIGINT)
        clear
        banner
        read -p "Enter the first three octets of the network to scan: " subnet
        clear
        banner
        echo -e "${LYELLOW}Press Ctrl-C to cancel the operation.${RESET}"
        echo "Scanning $subnet.0/24:"
        for host in $subnet.{1..254..1}; do
                [[ -n $CANCEL ]] && break # break if cancel is a number
                echo "$host..."
                ping -c 1 $host > /dev/null
                if [ $? -eq 0 ]; then
                        echo -e "       ${LGREEN}ALIVE${RESET}"
                        numAlive=$((numAlive+1))
                        aliveList+=( "$host" )
                else
                        # if no response, check arp table
                        arp -n | grep $host
                        echo -e "       ${YELLOW}No response.${RESET}"
                fi
        done
        echo ""
        echo -e "Alive hosts: ${CYAN}$numAlive${RESET}"
        for alivehost in "${aliveList[@]}"; do
                echo "  $alivehost"
        done
        echo ""
        echo "Press Enter to return to main menu."
        read -p ""
        true
}

function colourviewer () {
        clear
        banner
        echo -e "${RED}Red              ${LRED}Light Red${RESET}"
        echo -e "${GREEN}Green          ${LGREEN}Light Green${RESET}"
        echo -e "${BLUE}Blue            ${LBLUE}Light Blue${RESET}"
        echo -e "${YELLOW}Yellow                ${LYELLOW}Light Yellow${RESET}"
        echo -e "${PURPLE}Purple                ${LPURPLE}Light Purple${RESET}"
        echo -e "${CYAN}Cyan            ${LCYAN}Light Cyan${RESET}"
        echo ""
        echo "Press Enter to return to main menu."
        read -p ""
        true
}

function mainmenu () {
        clear
        banner
        echo "-----------------Options-----------------"
        echo "1. System Info            2. Processes"
        echo "3. Date & Time            4. Clear TTY"
        echo "5. Inode Finder           6. IP Scanner"
        echo "7. Colour Viewer  8. Classify Path"
        echo "9. Exit"
        echo ""
        read -p "Selection: " selection

        case "$selection" in
                "1" )
                        sysinfo
                        true ;;
                "2" )
                        top
                        true ;;
                "3" )
                        datetime
                        true ;;
                "4" )
                        clear
                        echo "The TTY is cleared every time the main menu is displayed or you select an option. Since this was part of the requirements, I added it anyway. Press Enter to return to the main menu."
                        read -p ""
                        true ;;
                "5" )
                        inodefinder
                        true ;;
                "6" )
                        ipscan
                        true ;;
                "7" )
                        colourviewer
                        true ;;
                "8" )
                        classifypath
                        true ;;
                "9" )
                        false ;;
                * )
                        true ;;
        esac
}

# clear the tty
clear

# show banner
banner

# authenticate user
if authenticate; then
        clear
        banner
        echo "Authentication Success. Welcome back, $username!"
        echo "Please press Enter."
        read -p ""
        while mainmenu; do
                true
        done
        clear
else
        clear
        banner
        echo -e "${RED}You ${LRED}failed to authenticate${RED}, this incident has been reported.${RESET}"
        echo "Press Enter to exit..."
        read -p ""
        clear
fi
