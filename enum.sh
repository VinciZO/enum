#!/bin/bash
# ./enum IP (will create folders from current path)
PORTS=("80/tcp" "8000/tcp" "8080/tcp" "8888/tcp" "1080/tcp" "443/tcp")

mkdir -p ./nmap
mkdir -p ./gobuster
nmap $1 -sC -sV -oN ./nmap/$1.init

for PORT in "${PORTS[@]}"; do
        if grep -q "^$PORT" "./nmap/$1.init"; then
                echo
                echo "There is a webserver on: $PORT  Starting gobuster..."
                gobuster dir -u http://$1 -w /usr/share/wordlists/dirb/common.txt -x txt,pdf,config,php -o ./gobuster/$1.extension
                gobuster dir -u http://$1 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o ./gobuster/$1.directory
        else
                echo
                echo "No webserver on: $PORT"
        fi
done
echo

MODIFIED_PORTS=()

for PORT in "${PORTS[@]}"; do
    # Remove /tcp from each item and add to the new array
    MODIFIED_PORTS+=("${PORT%/tcp}")
done

PORTS=("${MODIFIED_PORTS[@]}")

for PORT in "${PORTS[@]}"; do
        whatweb http://$1:$PORT | tee -a ./gobuster/whatweb.$1
done

echo "Starting nmap on all ports, this might take a while..."
nmap $1 -p- -oN ./nmap/$1.allPorts
