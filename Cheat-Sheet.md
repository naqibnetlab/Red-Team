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
- **Nmap syntax**
```
nmap <scan-types> <options> <target>
```
- **Nmap Scan Techniques**
```
SYN Scan (-sS): Stealthy, half-open handshake.
Connect Scan (-sT): Full TCP connection.
UDP Scan (-sU): Slower, stateless protocol.
```
- **Nmap Host Discovery**
```
nmap -sn 10.129.2.0/24           # Scan network range for hosts only (no ports)
nmap –iL hosts.txt               # Scan IP list in “hosts.txt” file
nmap 10.129.2.28-30              # Scan multiple IPs
```
- **Nmap Service & Version Detection**
```
nmap -sV 10.129.2.28-29          # detect service versions running on the target hosts
```
- **Nmap OS Detection**
```
nmap –O 10.129.2.28-29           #  Detect the operating system of the target
```
- **Nmap Scripting Engine (NSE)**
```
nmap --script <script name> <target address>
Example: nmap --script vuln 10.129.2.28

Common scripts: vuln, auth, brute, discovery, exploit

HINT: add –-min-rate 5000 to speed up scan, BUT this may cause errors or crashes...
```
- **Nmap Saving Results**
```
Formats: -oN (Normal), -oG (grepable), -oX (XML), -oA (all formats)
Example: nmap –oA scan_results 10.129.2.28-29
Files Generated: scan_results.nmap, scan_results.gnmap, scan_results.xm
```
- **Nmap Recommended Scans**
```
sudo nmap –A --script vuln –vv –p-–oX target_scan.xml –iL hosts.txt –-min-rate 5000 –-stats-every=5s

-A means –sV –sC –O
-vv means verbose output
-p- means scan all ports
-oX means output to xml file
--script vuln means run vulnerability scan script
```
- **Nmap View Results in Browser**
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
### enum4linux
```
```

## 3. GoBuster
```

```


