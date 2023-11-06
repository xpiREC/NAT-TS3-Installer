#!/bin/bash
# Easy TeamSpeak 3 installer for Debian based OS

# Check for root account
if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
  exit 1
fi

# Check supported OS
if [ -e '/etc/redhat-release' ] ; then
  echo 'Error: Sorry, this installer works only on Debian or Ubuntu'
  exit 1
fi

# Installation of dependent packages
apt update -y
apt install jq curl wget tar bzip2 -y

# Gives user the internal ip for reference and ask for desired ports
read -p "Enter Voice Server port: " vport
while true; do
  if ! [[ "$vport" =~ ^[0-9]+$ ]] || [[ "$vport" -lt "1" ]] || [[ "$vport" -gt "65535" ]]; then
    echo "Voice Server port invalid."
    echo "Available ports for your server can be found in the Network tab in dash."
    read -p "Re-enter Voice Server port: " vport
  else
    break
  fi
done

read -p "Enter File Transfer port: " fport
while true; do
  if ! [[ "$fport" =~ ^[0-9]+$ ]] || [[ "$fport" -lt "1" ]] || [[ "$fport" -gt "65535" ]]; then
    echo "File Transfer port invalid."
    echo "Available ports for your server can be found in the Network tab in dash."
    read -p "Re-enter File Transfer port: " fport
  else
    break
  fi
done

read -p "Enter Server Query port: " qport
while true; do
  if ! [[ "$qport" =~ ^[0-9]+$ ]] || [[ "$qport" -lt "1" ]] || [[ "$qport" -gt "65535" ]]; then
    echo "Server Query port invalid."
    echo "Available ports for your server can be found in the Network tab in dash."
    read -p "Re-enter Server Query port: " qport
  else
    break
  fi
done

rapass=$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c32)
read -p "Enter Server Query Admin password [$rapass]: " apass
if [[ "$apass" == "" ]]; then
  apass=$rapass
fi

# Create non-privileged user for TS3 server, and moves home directory under /etc
adduser --disabled-login --gecos "ts3server" ts3

# Get latest TS3 server version
echo "-------------------------------------------------------"
echo "Detecting latest TeamSpeak 3 version, please wait..."
echo "-------------------------------------------------------"
ts3version=$(curl -s https://www.teamspeak.com/versions/server.json | jq -r .linux.x86_64.version)

if [[ $ts3version =~ ^[3-9]+\.[1-9]+\.[0-9]+$ ]]; then
  wget --spider -q https://files.teamspeak-services.com/releases/server/${ts3version}/teamspeak3-server_linux_amd64-${ts3version}.tar.bz2 -o /home/ts3/teamspeak3-server_linux.tar.bz2
else
  echo "Error: Incorrect teamspeak server version composition detected"
  exit 1
fi
if [[ $? == 0 ]]; then
  break
fi


# Extract the contents and give correct ownership to the files and folders
echo "------------------------------------------------------"
echo "Extracting TeamSpeak 3 Server Files, please wait..."
echo "------------------------------------------------------"
tar -xjf /home/ts3/teamspeak3-server_linux.tar.bz2 --strip 1 -C /home/ts3/
rm -f /home/ts3/teamspeak3-server_linux.tar.bz2
chown -R ts3:ts3 /home/ts3/

# Create autostart script
cat > /etc/init.d/teamspeak3 <<"EOF"
#!/bin/sh
### BEGIN INIT INFO
# Provides:          TeamSpeak 3 Server
# Required-Start:    networking
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: TeamSpeak 3 Server Daemon
# Description:       Starts/Stops/Restarts the TeamSpeak 3 Server Daemon
### END INIT INFO

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="TeamSpeak 3 Server"
NAME=ts3
USER=ts3
DIR=/home/ts3/
DAEMON=$DIR/ts3server_startscript.sh
SCRIPTNAME=/etc/init.d/$NAME

test -x $DAEMON || exit 0

cd $DIR
sudo -u ts3 ./ts3server_startscript.sh $1
EOF
chmod 755 /etc/init.d/teamspeak3

# Assign right ports and password to TS3 server
sed -i "s/{2}/{4} default_voice_port=$vport query_port=$qport filetransfer_port=$fport filetransfer_ip=0.0.0.0 serveradmin_password=$apass/" /home/ts3/ts3server_startscript.sh

# Set TS3 server to auto start on system boot
update-rc.d teamspeak3 defaults

# Get the external public IP of the server
pubip=$(wget -qO- http://ipinfo.io/ip)

# Give user all the information
echo ""
echo ""
echo "TeamSpeak 3 has been successfully installed!"
echo "Voice server is available at $pubip:$vport"
echo "The file transfer port is: $fport"
echo "The server query port is: $qport"
echo ""
read -p "Start the server now? [y/n]: " startopt
sleep 1
if [ "$startopt" == "y" ] || [ "$startopt" == "yes" ]; then
  echo "Please keep the following details safe!"
  sleep 2
  /etc/init.d/teamspeak3 start
else
  echo "Run the following command to manually start the server:"
  echo "/etc/init.d/teamspeak3 start"
fi

exit 0
