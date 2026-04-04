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

# Step 2: Weaponization
