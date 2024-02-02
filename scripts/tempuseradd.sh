#!/bin/bash
#Very simple quick and dirty temporary account add with random password generated on the fly.
# randompass.sh is the script used to create the random pass

#Check if the current user is root
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        root="false"
        return
    fi
}

#Add a temporary basic user that is automatically disabled after 1 day from the time the script was run.
function tempuseradd () {
    check_root
    if [[ $root == "false" ]]; then
        echo "ERROR: This script requires root privileges. Please run as root user."
    else
        local username="tempuser"
        local password=$(./randompass.sh)
        local group="tempgroup"
        local uuid="3210"
        local guuid="3210"
        local TodaysDate=$(date +%Y-%m-%d -d today)
        local dateplus1=$(date +%Y-%m-%d -d "$myDate + 1 days")
        groupadd "$group" -g "$guuid"
        useradd -m "$username" -d "/home/$username" -c "Temporary vendor access" -e "$dateplus1" -g "$guuid" -s "/bin/bash" -u "$uuid"
        echo "$username:$password" | chpasswd
        id $username
        echo "User $username has been added to host - `hostname` and will expire on $dateplus1.  The temporary password is $password"
    fi
}

#Handy function to remove the user
function userrm () {
    check_root
    if [[ $root == "false" ]]; then
        echo "ERROR: This script requires root privileges. Please run as root user."
    else
        local username="tempuser"
        local group="tempgroup"
        userdel $username
        groupdel $group
        echo "$username has been removed along with the group $group.  Home directory is still on the system.  Can be removed manually if not needed."
    fi
}
