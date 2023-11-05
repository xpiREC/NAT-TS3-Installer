## NAT TS3 Installer
This installer will automatically install TeamSpeak 3 onto your NAT VPS, and automatically configure the ports to the ones you specify.

### How do I install?
To install TeamSpeak 3 automatically, run this command and follow the prompt.

``wget https://bit.ly/teamspeak-nat --no-check-certificate -O /tmp/nat_ts3.sh && bash /tmp/nat_ts3.sh``

### Requirements
This script will only work on OpenVZ container based VPS due to the fact it only checks for venet ethernet adapter. You can modify the code of this script before you run it if you want to install on a KVM/Xen VPS.

### Will this script work with VPS with dedicated IPs (all ports available)?
Yes, everything will work! Just use 9987 (default port) as your voice server port, 30033 as your file transfer port, and 10011 as your server query port. Of course if you want custom ports, you can set them to whatever you want as long as you have access to those ports and are opened in your firewall rules.

### I can't remember the port number, help!
You can also set up SVR records with your dns provider so you can use your hostname instead and do not have to remember your port number. For instructions on how to have this set up, please visit the <a href="https://support.teamspeakusa.com/index.php?/Knowledgebase/Article/View/293/12/does-teamspeak-3-support-dns-srv-records" target="_blank">TeamSpeak3 support page</a>.

### Does my server have a license?
No. Only the barebone server will be installed, no license will be included. You can, however, use the server as is for personal usage, up to 32 concurrent clients.<br />
If you need to upload your own license, you can upload your "licensekey.dat" to ```/home/ts3/``` and enter command ```/etc/init.d/teamspeak3 restart``` for the new license key to take effect.
