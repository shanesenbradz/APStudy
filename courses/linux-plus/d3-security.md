# MODULE security | Security | Linux+ · Domain 3 (18%) | #BE185D

## CONCEPT sec-perms | Permissions, ACLs and Special Bits
idea: Every file has an owner, a group and read, write and execute bits for owner, group and others. ACLs and special bits add finer control.
point: r = 4, w = 2, x = 1. Add them per digit: 750 is rwxr-x---.
point: umask removes bits from new files (base 666) and directories (base 777).
point: SUID = 4, SGID = 2, sticky = 1 in front of the three digits.
point: setfacl gives one extra user or group access. chattr +i makes a file immutable.
memory: 4-2-1 for r-w-x. SUID-SGID-Sticky is also 4-2-1.
card: Values of r, w, x? => r = 4, w = 2, x = 1.
card: Special bit values? => SUID = 4, SGID = 2, sticky = 1 (the leading digit).
card: umask 022 gives files and folders what? => Files 644, folders 755 (from 666 and 777).
card: Sticky bit on a folder does what? => Only the file owner (or root) can delete files. /tmp uses it.
card: SGID on a folder does what? => New files inherit the folder's group.
card: Give one user access without changing owner? => setfacl -m u:bob:r file. Check with getfacl.
card: Make a file unchangeable, even by root? => chattr +i file. Undo with chattr -i.
card: Find all SUID files? => find / -perm -4000

@mc
Q: Which command finds all files with the SUID bit set under /usr?
* find /usr -perm -4000
- find /usr -perm 4000 -type s
- grep -r suid /usr
- lsattr -R /usr | grep s
E: -perm -4000 matches any file that has the SUID bit, whatever its other bits are.

@mc
Q: Which chmod command sets SUID on a script and gives rwxr-xr-x to everyone else?
* chmod 4755 script.sh
- chmod 2755 script.sh
- chmod 6755 script.sh
- chmod 1755 script.sh
E: The leading 4 is SUID. 2 would be SGID, 1 sticky and 6 both SUID and SGID.

@calc
Q: What numeric mode gives rwxr-x--- (owner all, group read and execute, others nothing)?
A: 750
E: Owner 4+2+1 = 7, group 4+1 = 5, others 0.

@calc
Q: The umask is 027. What numeric permissions does a newly created regular file get?
A: 640
E: Files start from 666. Removing 027 gives 640 (rw-r-----).

@mc
Q: The user bob needs read access to report.txt without changing its owner or group. Which command does this?
* setfacl -m u:bob:r report.txt
- chmod o+r report.txt
- chown bob report.txt
- getfacl -m u:bob:r report.txt
E: setfacl -m adds an ACL entry for one user. chmod o+r would open it to everyone.

@mc
Q: Which command shows the ACL entries on a file?
* getfacl report.txt
- setfacl -l report.txt
- ls -Z report.txt
- lsattr report.txt
E: getfacl prints the ACL. ls -l shows a + at the end of the mode when an ACL exists.

@mc
Q: In the shared folder /shared, users must only be able to delete their own files. What should be set?
* The sticky bit, with chmod +t /shared
- SUID, with chmod u+s /shared
- SGID, with chmod g+s /shared
- The immutable flag, with chattr +i /shared
E: The sticky bit lets only the file owner (or root) delete or rename files. /tmp uses it.

@mc
Q: What does the SGID bit do when it is set on a directory?
* New files inside inherit the directory's group
- Files run with the group owner's rights
- Only the group owner can delete files
- The directory cannot be listed
E: SGID on a directory keeps team folders owned by the team group.

@mc
Q: A config file must not be changed or deleted, even by root, until the flag is removed. Which command does this?
* chattr +i /etc/app.conf
- chmod 000 /etc/app.conf
- chown nobody /etc/app.conf
- setfacl -b /etc/app.conf
E: The immutable attribute blocks writes, renames and deletes, even for root, until chattr -i is run.

@mc
Q: Which command makes www-data the owner and group of /var/www and everything inside it?
* chown -R www-data:www-data /var/www
- chmod -R www-data /var/www
- chgrp www-data /var/www
- chown www-data /var/www/*
E: chown -R changes owner and group recursively. chgrp alone changes only the group of one item.

@match
Q: Match each chmod command to what it does.
- chmod u+x file => Adds execute for the owner
- chmod g-w file => Removes write from the group
- chmod o= file => Removes all permissions from others
- chmod a+r file => Adds read for everyone
E: u, g, o and a mean user, group, others and all. + adds, - removes and = sets exactly.

@tf
Q: In ls -l output, a capital S in the owner execute position means SUID is set but the owner has no execute permission.
A: true
E: Lowercase s means SUID plus execute. Capital S means SUID without execute, which is usually a mistake.

@mc
Q: What does the execute (x) permission allow on a directory?
* Entering the directory and reaching files inside it
- Running every script in the directory
- Listing file names in the directory
- Creating new files in the directory
E: x lets you cd into the directory and use paths through it. r lists names and w creates or deletes entries.

## CONCEPT sec-access | Authentication, sudo and SSH
idea: Control who can log in and what they can do. Use keys for SSH, sudo for admin rights, and PAM for password rules.
point: Set PermitRootLogin no and PasswordAuthentication no in sshd_config once keys work.
point: ~/.ssh must be 700 and authorized_keys 600 or sshd refuses the key.
point: Edit sudo rules with visudo. Put drop-in files in /etc/sudoers.d/.
point: pam_pwquality sets password strength. pam_faillock locks accounts after failed logins.
memory: Test the key, then lock the door. Never disable passwords before a key login works.
card: Block root SSH logins? => PermitRootLogin no in sshd_config.
card: Key-only SSH logins? => PasswordAuthentication no, after you test a key login.
card: Make and install an SSH key? => ssh-keygen -t ed25519, then ssh-copy-id user@host.
card: Required permissions for SSH keys? => ~/.ssh 700, authorized_keys 600.
card: Edit sudoers safely? => visudo. Use drop-in files in /etc/sudoers.d/.
card: PAM module for password strength? Lockouts? => pam_pwquality. pam_faillock.
card: Local port forward through SSH? => ssh -L 8080:localhost:80 user@server
card: Show failed logins? => lastb (reads /var/log/btmp).

@mc
Q: Which sshd_config directive stops direct root logins over SSH?
* PermitRootLogin no
- AllowRootLogin no
- RootLogin deny
- DisableRoot yes
E: PermitRootLogin no blocks root. Admins log in as themselves and use sudo.

@mc
Q: Which command generates a modern Ed25519 SSH key pair?
* ssh-keygen -t ed25519
- ssh-keygen -t rsa-4096 -m ed25519
- ssh-copy-id -t ed25519
- openssl genpkey -ed25519 ~/.ssh/id
E: ssh-keygen -t ed25519 creates the key pair. ssh-copy-id then installs the public key on a server.

@mc
Q: Which command must be used to edit the sudoers file safely with a syntax check?
* visudo
- nano /etc/sudoers
- sudoedit /etc/sudoers.d
- vipw
E: visudo locks the file and checks syntax before saving, so a typo cannot break sudo.

@mc
Q: Which tool reads logs such as /var/log/auth.log and bans IP addresses with repeated failed logins through firewall rules?
* fail2ban
- aide
- snort
- logwatch
E: fail2ban watches logs and adds temporary firewall bans for offending addresses.

@mc
Q: Which command installs your public key in the authorized_keys file on server01?
* ssh-copy-id admin@server01
- ssh-keygen -c admin@server01
- scp ~/.ssh/id_ed25519 admin@server01:
- ssh-add admin@server01
E: ssh-copy-id appends the public key to the remote authorized_keys with the right permissions. Never copy the private key.

@mc
Q: Key logins work for every admin. Which sshd_config setting now turns off password logins?
* PasswordAuthentication no
- PubkeyAuthentication no
- UsePAM no
- ChallengeResponse yes
E: PasswordAuthentication no allows keys only. PubkeyAuthentication no would block the keys instead.

@mc
Q: Where should a new sudo rule for the backup team be placed so it survives package updates?
* A new file in /etc/sudoers.d/, edited with visudo -f
- The end of /etc/sudoers.bak
- /etc/sudo.conf
- ~/.sudo_as_admin_successful
E: Drop-in files in /etc/sudoers.d/ keep custom rules apart from the main file. visudo -f checks their syntax.

@mc
Q: Which sudoers line lets every member of the wheel group run any command as any user?
* %wheel ALL=(ALL) ALL
- wheel ALL=(ALL) ALL
- @wheel ALL:ALL
- %wheel NOPASSWD
E: % marks a group. The format is who host=(runas) commands.

@mc
Q: Which PAM module enforces password length and complexity rules?
* pam_pwquality
- pam_faillock
- pam_limits
- pam_unix_session
E: pam_pwquality checks new passwords against rules such as minlen and dcredit.

@mc
Q: Accounts must lock for 15 minutes after five failed logins. Which PAM module handles this?
* pam_faillock
- pam_pwquality
- pam_env
- pam_motd
E: pam_faillock counts failures and locks the account. faillock --user name --reset unlocks it.

@mc
Q: SSH key login fails with Permission denied (publickey). The key is in authorized_keys. Which permissions should be set?
* chmod 700 ~/.ssh and chmod 600 ~/.ssh/authorized_keys
- chmod 777 ~/.ssh and chmod 666 ~/.ssh/authorized_keys
- chmod 755 ~/.ssh and chmod 644 ~/.ssh/id_ed25519
- chmod 000 ~/.ssh
E: With StrictModes on, sshd ignores keys if the folder or file is writable by others.

@mc
Q: An admin needs to reach a web app on port 80 that only listens on the server's localhost. Which command creates a tunnel from local port 8080?
* ssh -L 8080:localhost:80 admin@server
- ssh -R 80:localhost:8080 admin@server
- ssh -D 8080 admin@server
- ssh -p 8080 admin@server:80
E: -L forwards a local port to a destination as seen from the server. -R is a reverse tunnel and -D is a SOCKS proxy.

@order
Q: SIMULATION: Move a server to key-only SSH logins without locking yourself out. Put the steps in order.
- Generate a key pair on your workstation with ssh-keygen
- Copy the public key to the server with ssh-copy-id
- Test a key login in a new terminal and keep the old session open
- Set PasswordAuthentication no in /etc/ssh/sshd_config
- Reload sshd
E: Prove the key works before you turn off passwords, and keep a working session open as a safety net.

@mc
Q: Which command joins a Linux server to an Active Directory domain using SSSD?
* realm join ad.example.com
- net ads leave ad.example.com
- ldapadd -D ad.example.com
- kinit --join ad.example.com
E: realm join discovers the domain, joins it and configures SSSD. kinit only gets a Kerberos ticket.

@mc
Q: Which command lists failed login attempts recorded on the system?
* lastb
- last
- who -a
- w -f
E: lastb reads /var/log/btmp, which records bad logins. last reads successful ones.

## CONCEPT sec-mac | SELinux and AppArmor
idea: SELinux and AppArmor add mandatory access control on top of normal permissions. A file can be 777 and still be blocked.
point: getenforce or sestatus shows the mode: enforcing, permissive or disabled.
point: ls -Z shows contexts. restorecon resets them to policy.
point: semanage fcontext makes a context rule permanent. setsebool -P makes a boolean permanent.
point: AppArmor uses path-based profiles. aa-complain logs without blocking.
memory: Check the context before you blame the permissions.
card: Show SELinux mode? => getenforce or sestatus.
card: Switch to permissive until reboot? => setenforce 0 (setenforce 1 for enforcing).
card: Show file contexts? => ls -Z
card: Reset contexts to policy? => restorecon -Rv /path
card: Make a custom path's context permanent? => semanage fcontext -a -t type "/path(/.*)?", then restorecon.
card: Make a boolean permanent? => setsebool -P name on
card: Allow a web server on a new port? => semanage port -a -t http_port_t -p tcp 8443
card: AppArmor log-only mode? => aa-complain profile. aa-enforce turns blocking back on.

@mc
Q: An administrator must set SELinux to permissive mode for debugging without rebooting. Which command does this?
* setenforce 0
- selinux --permissive
- setsebool permissive 1
- getenforce -p
E: setenforce 0 switches to permissive until reboot. setenforce 1 goes back to enforcing.

@mc
Q: Which TWO commands show the current SELinux mode? (Choose two.)
* getenforce
* sestatus
- setenforce
- semanage boolean
E: getenforce prints the mode. sestatus prints the mode and more detail.

@mc
Q: Files copied into /var/www/html have the wrong SELinux context and the web server gets 403 errors. Which command fixes the contexts?
* restorecon -Rv /var/www/html
- chcon -R --reset /var/www/html
- chmod -R 755 /var/www/html
- setenforce 1
E: restorecon resets contexts to what the policy says that path should have.

@mc
Q: Web content lives in a custom folder /web. Which commands make the correct context stick, even after a relabel?
* semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?" then restorecon -Rv /web
- chcon -R -t httpd_sys_content_t /web only
- setsebool -P httpd_web 1
- chmod -R 755 /web then restorecon
E: chcon changes are lost on relabel. semanage fcontext adds a lasting rule and restorecon applies it.

@mc
Q: The web server must connect to a remote database under SELinux, and the change must survive reboots. Which command does this?
* setsebool -P httpd_can_network_connect on
- setsebool httpd_can_network_connect on
- semanage port -a httpd
- setenforce 0
E: -P writes the boolean to the policy so it persists. Without -P it lasts until reboot.

@mc
Q: nginx must listen on TCP 8443 on an SELinux enforcing system. Which command allows it?
* semanage port -a -t http_port_t -p tcp 8443
- setsebool -P nginx_port_8443 on
- firewall-cmd --add-port=8443/tcp only
- restorecon -p 8443
E: SELinux only lets web servers bind to ports labelled http_port_t. Add the port to that type.

@mc
Q: Which command shows the SELinux context of files?
* ls -Z
- ls -l
- getfacl
- lsattr
E: -Z adds the user:role:type:level context to the listing.

@mc
Q: An AppArmor profile is blocking nginx. The admin wants to log violations without blocking them while testing. Which command does this?
* aa-complain /etc/apparmor.d/usr.sbin.nginx
- aa-enforce /etc/apparmor.d/usr.sbin.nginx
- aa-status --off nginx
- setenforce 0
E: Complain mode logs what would be blocked. aa-enforce turns blocking back on.

@order
Q: SIMULATION: A service fails only when SELinux is enforcing. Put the troubleshooting steps in order.
- Reproduce the failure
- Look for denials with ausearch -m avc -ts recent
- Read the suggested cause with audit2why or sealert
- Apply the fix with restorecon, setsebool or semanage
- Retest the service in enforcing mode
E: Find the actual denial, understand it, fix the label, boolean or port, then test with SELinux still enforcing.

## CONCEPT sec-firewall | Firewalls
idea: A host firewall decides which traffic may reach the server. firewalld and ufw are friendly front ends. nftables and iptables are the engines.
point: firewall-cmd changes are runtime only unless you add --permanent and reload.
point: Rules are checked top down. The first match wins.
point: ufw default deny incoming plus explicit allows is a solid baseline.
point: nft list ruleset shows everything nftables is doing.
memory: firewalld: permanent, then reload, or it is gone.
card: Make a firewalld rule permanent? => Add --permanent, then firewall-cmd --reload.
card: Show everything in the active zone? => firewall-cmd --list-all
card: ufw baseline? => ufw default deny incoming, ufw allow 22/tcp, ufw enable.
card: Show the nftables rules? => nft list ruleset
card: How are firewall rules matched? => Top down. The first match wins.
card: iptables append vs insert? => -A adds to the end. -I adds at the top (or a position).
card: Drop traffic from one IP with iptables? => iptables -A INPUT -s 203.0.113.5 -j DROP
card: Move an interface to a firewalld zone? => firewall-cmd --permanent --zone=internal --change-interface=eth1

@mc
Q: A web server is reachable on HTTP but HTTPS connections fail. Exhibit: $ ufw status → 443/tcp DENY Anywhere; 80/tcp ALLOW Anywhere | $ ss -tlnp → LISTEN 0.0.0.0:443 nginx. Which command best fixes this?
- ufw disable
- ufw allow 80/tcp
* ufw delete deny https/tcp
- ufw allow 4096/tcp
E: nginx is listening on 443 but a deny rule blocks it. Deleting that rule fixes it and keeps the firewall on.

@mc
Q: Which ufw commands build a firewall that blocks unsolicited inbound traffic but allows outbound traffic and inbound SSH?
* ufw default deny incoming; ufw allow 22/tcp; ufw enable
- ufw deny all in; ufw permit ssh
- ufw policy drop; ufw enable ssh
- ufw reject incoming && ufw allow OpenSSH && ufw on
E: Deny incoming by default, allow what you need, then enable.

@mc
Q: Which commands allow HTTPS permanently with firewalld and apply it now?
* firewall-cmd --permanent --add-service=https && firewall-cmd --reload
- firewall-cmd --add-service=https
- firewall-cmd --reload --add-service=https
- systemctl restart firewalld --https
E: --permanent writes the rule to disk and --reload loads it into the running firewall.

@mc
Q: Which command shows every setting in the active firewalld zone?
* firewall-cmd --list-all
- firewall-cmd --get-zones
- firewall-cmd --state
- iptables -L --zone
E: --list-all shows interfaces, services, ports and rich rules for the zone.

@mc
Q: Which command prints the complete nftables configuration that is running?
* nft list ruleset
- nft show all
- iptables -S
- nft flush ruleset
E: nft list ruleset prints every table, chain and rule. flush would delete them all.

@mc
Q: Which iptables command drops all traffic from 203.0.113.5?
* iptables -A INPUT -s 203.0.113.5 -j DROP
- iptables -A OUTPUT -d 203.0.113.5 -j ACCEPT
- iptables -D INPUT -s 203.0.113.5
- iptables -P INPUT 203.0.113.5 DROP
E: -A INPUT appends to the inbound chain, -s matches the source and -j DROP discards it.

@tf
Q: A port opened with firewall-cmd --add-port=8080/tcp, without --permanent, is lost after the firewall reloads or the server reboots.
A: true
E: Without --permanent only the runtime config changes.

@mc
Q: An admin appended an ACCEPT rule for port 22, but SSH is still blocked. iptables -L shows a DROP-all rule above it. What fixes it?
* iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
- iptables -A INPUT -p tcp --dport 22 -j ACCEPT again
- iptables -P INPUT ACCEPT --after
- iptables -F OUTPUT
E: Rules are read top down and the first match wins. -I inserts the rule above the DROP.

@match
Q: Match each command to the firewall it manages.
- firewall-cmd => firewalld zones and services
- ufw => Uncomplicated Firewall on Debian and Ubuntu
- nft => nftables tables and chains
- iptables-save => Dump of legacy iptables rules
E: Use the tool that matches the firewall service actually running on the host.

@mc
Q: The interface eth1 faces the trusted internal network. Which command permanently moves it to the internal zone?
* firewall-cmd --permanent --zone=internal --change-interface=eth1
- firewall-cmd --zone=eth1 --set-target=internal
- nmcli con mod eth1 firewall internal-zone
- ufw route allow in on eth1
E: --change-interface assigns the interface to the zone. Add --permanent so it survives reloads.

## CONCEPT sec-crypto | Encryption, Integrity and Auditing
idea: Encrypt data at rest, prove files have not changed, and record who did what.
point: LUKS (cryptsetup) encrypts whole partitions. GPG encrypts files.
point: sha256sum creates and checks file checksums.
point: AIDE builds a baseline and reports changed files.
point: auditd records events. auditctl adds watch rules. ausearch finds them by key.
memory: Lock (LUKS), Seal (GPG), Check (sha256sum, AIDE), Watch (auditd).
card: Encrypt a partition? => cryptsetup luksFormat /dev/sdb1
card: Unlock a LUKS partition? => cryptsetup open /dev/sdb1 name (appears in /dev/mapper/).
card: Encrypt a file for one person? => gpg --encrypt --recipient them@example.com file
card: Check a download's integrity? => sha256sum file, compare with the vendor's hash.
card: Tool that reports changed system files? => AIDE (aide --init, then aide --check).
card: Watch a file with auditd? => auditctl -w /etc/passwd -p wa -k key. Search with ausearch -k key.
card: See a server's TLS certificate? => openssl s_client -connect host:443
card: Symmetric vs asymmetric examples? => Symmetric: AES. Asymmetric: RSA, ECDSA, Ed25519.

@mc
Q: Which auditctl command watches /etc/passwd for writes and attribute changes and tags events with the key userdb?
* auditctl -w /etc/passwd -p wa -k userdb
- auditctl -a /etc/passwd -k userdb -m wa
- auditctl -W /etc/passwd -p w -K userdb
- ausearch -f /etc/passwd -k userdb
E: -w sets the watch path, -p wa picks write and attribute changes, and -k sets a key for searching.

@mc
Q: Which command shows the TLS certificate presented by the web server at www.example.com?
* openssl s_client -connect www.example.com:443
- openssl x509 -in www.example.com -text
- curl --cert www.example.com
- nmap --script ssl-cert www.example.com
E: s_client opens a TLS connection and prints the certificate chain. x509 -in reads a certificate file you already have.

@mc
Q: Which command sets up LUKS encryption on /dev/sdb1? (All data on it will be lost.)
* cryptsetup luksFormat /dev/sdb1
- cryptsetup open /dev/sdb1 secure
- mkfs.luks /dev/sdb1
- gpg --encrypt /dev/sdb1
E: luksFormat writes the LUKS header and sets the passphrase. open unlocks an existing LUKS device.

@mc
Q: Which command unlocks the LUKS partition /dev/sdb1 as /dev/mapper/securedata?
* cryptsetup open /dev/sdb1 securedata
- cryptsetup luksFormat /dev/sdb1 securedata
- mount -t luks /dev/sdb1 /securedata
- cryptsetup close securedata
E: open maps the decrypted device under /dev/mapper. Then you mount that mapper device.

@mc
Q: Which command creates a SHA-256 checksum of an ISO file to compare with the vendor's value?
* sha256sum rocky.iso
- md5sum -256 rocky.iso
- gpg --hash rocky.iso
- openssl enc -sha256 rocky.iso
E: sha256sum prints the hash. Compare it with the published one, or check a list with sha256sum -c.

@mc
Q: Which command encrypts report.pdf so only alice@example.com can open it with her private key?
* gpg --encrypt --recipient alice@example.com report.pdf
- gpg --sign report.pdf
- gpg --symmetric --recipient alice@example.com report.pdf
- openssl passwd report.pdf
E: Encrypting to a recipient uses their public key. --sign proves who sent it but does not hide it.

@mc
Q: Which command creates a self-signed certificate and a new unencrypted private key, valid for 365 days?
* openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
- openssl genrsa -x509 -out cert.pem 365
- ssh-keygen -t x509 -days 365
- openssl s_client -new -days 365
E: req -x509 makes a self-signed certificate instead of a request. -nodes leaves the key without a passphrase.

@mc
Q: Which tool builds a database of file hashes and later reports which system files changed?
* AIDE
- fail2ban
- logrotate
- rkhunter-gui
E: AIDE stores a baseline with aide --init and compares the system against it with aide --check.

@mc
Q: Which command finds audit events tagged with the key userdb?
* ausearch -k userdb
- auditctl -l userdb
- journalctl -k userdb
- aureport --key-delete userdb
E: ausearch -k searches the audit log by key. auditctl -l lists the loaded rules.

@mc
Q: A server runs a legacy service that nobody uses. What is the best hardening step?
* Stop and disable the service, or remove its package
- Change its port number
- Leave it running but hide it from ss output
- Give it a longer log retention
E: Fewer running services means less attack surface. Changing ports only hides it.

@mc
Q: Which algorithm is symmetric, using the same key to encrypt and decrypt?
* AES
- RSA
- Ed25519
- ECDSA
E: AES is symmetric. RSA, Ed25519 and ECDSA use public and private key pairs.
