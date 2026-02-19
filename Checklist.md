# Step 1. Reconnaissance
## 1. nmap
- **Nmap Recommended Scans**
```
sudo nmap –A --script vuln –vv –p-–oX target_scan.xml –iL hosts.txt

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

