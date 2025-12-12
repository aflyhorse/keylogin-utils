#!/bin/bash

if [[ -z $1 ]] ; then
    echo "Usage: $0 USERNAME"
    exit 128
elif [ $(id -u $1 2>/dev/null || echo -1) -ge 0 ] ; then
    echo "User $1 already exists."
    exit 1
fi

homedirs=( "/mnt/disk1" "/mnt/disk2" "/mnt/disk3" "/mnt/disk4" "/mnt/disk5" )

index=0
for home in ${homedirs[@]} ; do
    ((index++))
    # Extract usage percent from df
    usage=$(df -h "$home" 2>/dev/null | awk 'NR==2{print $5}')
    if [[ -z "$usage" ]] ; then
        usage="N/A"
    fi
    echo -e "\e[1m${index}) ${home} users (used: $usage):\e[0m"
    ls ${home}
done

echo ""
echo "Select a home for user $1 in 1..${#homedirs[@]}:"
select home in ${homedirs[@]} ; do
    if [[ -z $home ]] ; then
        echo "Please input a valid number in 1..${#homedirs[@]}."
    else
        echo "Home is set to $home/$1"
        break
    fi
done

read -p "Full name of this user ($1): " fname

echo "User $1 ($fname) will be created at $home/$1"
read -p "Confirm (y/n)? " confirm
if [[ "x$confirm" == "xy" ]] ; then
    /sbin/useradd -m -d "$home/$1" -c "$fname,,,," $1
    if [[ $? -eq 0 ]] ; then
        quotatool -u "$1" -b -l 20Tb "$home"
        # Prompt for SSH key
        read -p "Do you want to add an SSH public key for $1? (press ENTER to skip): " sshkey
        if [[ -n "$sshkey" ]] ; then
            echo "$sshkey" | ssh-keygen -l -f - >/dev/null 2>&1
            if [[ $? -eq 0 ]] ; then
                echo "$sshkey" | /usr/local/sbin/ssh-addkey $1 --stdin
                if [[ $? -eq 0 ]] ; then
                    echo "SSH key added for $1."
                else
                    echo "Failed to add SSH key for $1."
                fi
            else
                echo "Invalid SSH public key. Skipped."
            fi
        else
            echo "No SSH key provided. Skipped."
        fi
    fi
else
    echo "Aborted."
fi