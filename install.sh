#!/bin/bash
# tested on debian buster 

if ! [ $(id -u) = 0 ]; then
	echo "Run Script as root!"
	exit 1
else
	# update & packages
	apt update
	apt-get install ncdu ufw fail2ban net-tools dntutils curl git zsh --y
	echo "Please provide the other user & apply it with [ENTER]"
	read nonrootuser
	# change root & user shell
	chsh $USER -s /bin/zsh
	chsh $nonrootuser -s /bin/zsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" & 
	# issue.net
	echo "
********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the  *
* evidence from such monitoring to law enforcement officials.      *
*                                                                  *
********************************************************************
	" > /etc/issue.net	
	# ssh
	banner=Banner\ /etc/issue.net
	sed -i "s/.*Port.*/Port 7829/" /etc/ssh/sshd_config
	sed -i "s/.*PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
	sed -i "s/.*MaxAuthTries.*/MaxAuthTries 3/" /etc/ssh/sshd_config
	sed -i "s/.*MaxSessions.*/MaxSessions 6/" /etc/ssh/sshd_config
	sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/" /etc/ssh/sshd_config
	sed -i "s/.*Banner.*/Banner \/etc\/issue.net/" /etc/ssh/sshd_config
	# ufw
	ip=$(hostname -i)
	systemctl stop ufw ; systemctl enable ufw
	ufw allow from any to $ip port 7829 proto tcp
	systemctl start ufw 
	# fail2ban
	systemctl stop fail2ban ; systemctl enable fail2ban
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i "s/enabled =.*/enabled = true/" /etc/fail2ban/jail.local
	sed -i "s/banaction =/banaction = ufw/" /etc/fail2ban/jail.local
	sed -i "s/banaction_allports.*/banaction_allports = ufw/" /etc/fail2ban/jail.local
	sed -i "s/.*Port.*/Port 7829/" /etc/fail2ban/jail.local # SSHD bantime
	sed -i "s/.*Port.*/Port 7829/" /etc/fail2ban/jail.local # SSHD findtime
	sed -i "s/.*Port.*/Port 7829/" /etc/fail2ban/jail.local # SSHD maxretry
	sed -i "s/.*Port.*/Port 7829/" /etc/fail2ban/jail.local
	sed -i "s/.*Port.*/Port 7829/" /etc/fail2ban/jail.local
	
	
	# dynamic motd
	
