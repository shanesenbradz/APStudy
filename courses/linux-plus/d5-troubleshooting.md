# MODULE troubleshooting | Troubleshooting | Linux+ · Domain 5 (22%) | #B91C1C

## CONCEPT ts-boot | Boot and System Recovery
idea: When a system will not boot, find which stage failed: firmware, GRUB, kernel, initramfs or systemd. Each has its own fix.
point: emergency.target gives a root shell with almost nothing mounted. rescue.target mounts local filesystems.
point: A bad /etc/fstab line is the most common reason for dropping to emergency mode. nofail prevents it.
point: rd.break on RHEL stops in the initramfs so you can reset the root password.
point: journalctl -b -1 shows logs from the previous boot.
memory: GRUB menu, press e, edit the linux line. That is your way in.
card: emergency.target vs rescue.target? => emergency: root shell, root fs read-only, almost nothing else. rescue: local filesystems and basic services.
card: Remount root read-write? => mount -o remount,rw /
card: Reset the RHEL root password? => rd.break at GRUB, remount /sysroot rw, chroot, passwd, touch /.autorelabel.
card: Most common cause of emergency mode? => A bad or missing device in /etc/fstab. Use nofail for optional disks.
card: Find slow boot units? => systemd-analyze blame
card: Boot into rescue once from GRUB? => Add systemd.unit=rescue.target to the linux line.
card: New kernel won't boot? => Pick the old kernel in GRUB, then rebuild initramfs with dracut -f.
card: Set the default kernel on RHEL? => grubby --set-default /boot/vmlinuz-...

@mc
Q: A system booted with a read-only root filesystem after a power loss. Which command remounts / read-write for repairs?
* mount -o remount,rw /
- fsck --rw /
- mount -a -o rw
- systemctl remount-fs rw
E: remount,rw changes the mount options without unmounting.

@mc
Q: Which command shows kernel ring buffer messages, including hardware found during boot?
* dmesg
- lsmod
- lspci -k
- cat /var/log/kern.log --live
E: dmesg prints the kernel ring buffer. journalctl -k -b gives the same messages from the journal.

@mc
Q: A system fails to boot normally. Which systemd target gives a root shell with no services and only the root filesystem mounted read-only?
* emergency.target
- rescue.target
- single-user.target
- recovery.target
E: emergency is the most minimal. rescue also mounts local filesystems and starts a few basic services.

@mc
Q: Which kernel parameter, added at the GRUB menu on RHEL, stops boot inside the initramfs so the root password can be reset?
* rd.break
- init=/sbin/reboot
- single quiet
- nomodeset
E: rd.break drops to a shell before the real root is switched in. The real root is then at /sysroot.

@order
Q: SIMULATION: Reset a forgotten root password on RHEL 9. Put the steps in order.
- At the GRUB menu, highlight the entry and press e
- Add rd.break to the end of the linux line and boot with Ctrl+X
- Run mount -o remount,rw /sysroot then chroot /sysroot
- Run passwd root and set the new password
- Run touch /.autorelabel, then exit twice to reboot
E: The autorelabel step fixes the SELinux label on /etc/shadow. Without it, logins can fail after the reset.

@mc
Q: After a kernel update the server panics with "VFS: Unable to mount root fs". What is the quickest way to get it running?
* Boot the previous kernel from the GRUB menu, then rebuild the initramfs for the new one
- Reinstall the operating system
- Run fsck on every disk from the panic screen
- Disable SELinux in the BIOS
E: The older kernel still has a working initramfs. Boot it, then fix the new kernel with dracut -f.

@mc
Q: A server drops to emergency mode after a USB disk listed in /etc/fstab was removed. What is the right long-term fix?
* Remove the line or add the nofail option to that fstab entry
- Add the disk to /etc/hosts
- Set the default target to emergency.target
- Run grub2-install
E: Without nofail, systemd waits for the device and fails the boot when it is missing.

@mc
Q: Which command shows log messages from the boot before the current one?
* journalctl -b -1
- journalctl -b 0
- journalctl --last
- dmesg -1
E: -b 0 is the current boot and -b -1 the one before. The journal must be persistent for this to work.

@mc
Q: Boot takes three minutes. Which command lists the units that took longest to start?
* systemd-analyze blame
- systemctl list-timers
- journalctl --boot-time
- uptime -s
E: blame sorts units by start time. systemd-analyze critical-chain shows the slowest path.

@mc
Q: A server stops at a grub rescue prompt after a disk change. What is the usual fix?
* Boot from rescue media, chroot into the system and reinstall GRUB with grub2-install
- Run fsck from the grub rescue prompt
- Replace the CMOS battery
- Run dracut -f from the grub rescue prompt
E: GRUB cannot find its files. Reinstall it from a live or rescue environment, then rebuild grub.cfg.

@mc
Q: Which kernel parameter added at the GRUB menu boots into rescue mode for one boot?
* systemd.unit=rescue.target
- runlevel=rescue
- systemctl rescue
- init=rescue
E: systemd.unit= picks the target for this boot only. The default target is not changed.

@tf
Q: The nofail option in /etc/fstab lets the system finish booting even if that device is missing.
A: true
E: Use it for removable or network disks that are not needed to boot.

@mc
Q: On RHEL, which command makes a specific installed kernel the default boot entry?
* grubby --set-default /boot/vmlinuz-5.14.0-427.el9.x86_64
- grub2-install --default 5.14.0-427
- uname --set-default 5.14.0-427
- dnf default-kernel 5.14.0-427
E: grubby manages boot entries on RHEL. grubby --default-kernel shows the current default.

## CONCEPT ts-perf | Performance and Monitoring
idea: Slow systems usually run out of CPU, memory or disk I/O. Measure first, then fix the real bottleneck.
point: Load average higher than the CPU count (nproc) means CPU saturation.
point: High wa in top or iostat means the disk is the bottleneck.
point: Heavy swapping (si/so in vmstat) means not enough RAM.
point: The OOM killer leaves messages in dmesg and the journal.
memory: Load vs nproc. wa for wait. si/so for swap.
card: When is load average too high? => When it stays above the CPU count from nproc.
card: High wa in top means? => CPUs waiting on disk I/O. Check iostat -x and iotop.
card: Signs of memory pressure? => Low available memory and high si/so in vmstat.
card: Was a process OOM-killed? => journalctl -k | grep -i "out of memory" (or dmesg).
card: Per-core CPU use? => mpstat -P ALL 1
card: Past performance data? => sar (sysstat).
card: Zombie process? => State Z. Already exited. The parent must reap it.
card: Sort processes by CPU? Memory? => ps aux --sort=-%cpu, ps aux --sort=-%mem.

@mc
Q: A Linux administrator receives reports that an application is not finishing jobs in time. Exhibit: $ uptime → load average: 7.75, 5.72, 5.17 | $ nproc → 4 | $ free -m → plenty of free memory, swap unused | $ vmstat 1 → wa 0. Which action helps speed up the jobs?
- Increase the free memory available to the system
* Increase the CPU resources available to the system
- Increase the swap space available to the system
- Increase the number of disks available to the system
E: A load around 7 on 4 CPUs means processes are waiting for CPU. Memory, swap and disk wait all look fine.

@mc
Q: Which of the following describes collecting system events from many sources into a single location?
* Log aggregation
- Health checks
- Webhooks
- Threshold monitoring
E: Log aggregation collects logs from many hosts into one place so they can be searched together.

@mc
Q: Which tool reports per-disk I/O use and helps identify a storage bottleneck?
* iostat -x 1
- vmstat -m
- netstat -i
- lsof -i
E: iostat -x shows extended stats per device, including %util and wait times.

@mc
Q: Which command shows the top 10 processes by CPU use in one snapshot?
* ps aux --sort=-%cpu | head -11
- top -n1 -o memory
- htop --batch-cpu
- pgrep -c --cpu
E: ps sorted by CPU, descending, then head. 11 lines because the first is the header.

@mc
Q: Which command gives a readable summary of RAM and swap use?
* free -h
- vmstat -d
- cat /proc/meminfo --pretty
- top -m
E: free -h shows total, used, free, buffers and cache, and available memory, plus swap.

@mc
Q: Users report a slow server. Exhibit: $ free -h → Mem available 120Mi of 8Gi | Swap used 3.9Gi of 4Gi | $ vmstat 1 → si 850 so 920. What is the most likely cause?
* The server is short of RAM and swapping heavily
- The CPU is overheating
- The network card is faulty
- The disk is almost full
E: Very little available memory plus constant swap in (si) and out (so) means memory pressure.

@mc
Q: A database process vanished overnight. Which command best confirms the kernel killed it for lack of memory?
* journalctl -k | grep -i "out of memory"
- grep killed /etc/passwd
- systemctl list-timers
- free -h --history
E: The OOM killer logs "Out of memory: Killed process" in the kernel log.

@mc
Q: top shows 45.0 wa in the CPU line. What does this point to?
* CPUs are waiting on disk I/O
- The CPU is fully busy running user code
- Too many users are logged in
- The network is dropping packets
E: wa is I/O wait time. Check iostat and iotop to find the busy disk and process.

@mc
Q: Which tool shows, live, which processes are doing the most disk reads and writes?
* iotop
- iftop
- htop -n
- lsblk
E: iotop is top for disk I/O. iftop does the same for network traffic.

@tf
Q: On a server with 4 CPU cores, a load average of 4.0 means the CPUs are fully used but no processes are waiting.
A: true
E: Load equal to the core count is roughly full use. Above it, processes start queuing for CPU.

@mc
Q: ps shows several processes in state Z that will not go away. What are they, and how are they cleared?
* Zombie processes, cleared when their parent reaps them or the parent is restarted
- Sleeping processes, cleared with kill -9
- Kernel threads, cleared with a reboot only
- Swapped processes, cleared with swapoff
E: A zombie has already exited. Only its parent can collect its status. Fixing or restarting the parent clears it.

@mc
Q: A manager wants CPU use from yesterday afternoon. Which tool can report past performance data?
* sar -u
- top -b
- uptime
- mpstat -live
E: sar, from the sysstat package, reads data collected at set intervals.

@mc
Q: Which command lists processes sorted by memory use, highest first?
* ps aux --sort=-%mem
- ps aux --sort=%cpu
- free --sort
- pmap --top
E: The minus sign sorts in descending order.

@mc
Q: Which kernel setting controls how willing the system is to move memory pages to swap?
* vm.swappiness
- vm.overcommit_ratio
- kernel.panic
- fs.file-max
E: Lower swappiness keeps more in RAM. Set it with sysctl and save it in /etc/sysctl.d/ to persist.

@mc
Q: A monitoring rule sends an alert when disk use on / goes above 90%. What is this called?
* Threshold monitoring
- Log aggregation
- A webhook
- A health check
E: Threshold monitoring alerts when a metric crosses a set value.

@mc
Q: Overall CPU use looks low, but one app is slow. Which command shows use for each CPU core, to spot one core pinned at 100%?
* mpstat -P ALL 1
- vmstat -s
- uptime
- free -c
E: mpstat -P ALL breaks usage out per core. A single-threaded app can max one core while the average looks fine.

@match
Q: HOTSPOT: Match each symptom to the best first tool.
- One process is using a lot of CPU => top
- High disk wait time => iostat
- Heavy swap use => vmstat
- Network traffic per connection => iftop
E: Pick the tool that measures the resource the symptom points to.

## CONCEPT ts-net | Network Troubleshooting
idea: Work from the bottom up: link, address, gateway, remote IP, then DNS and the service port.
point: ip link shows if the link is up. ip addr shows the address. ip route shows the gateway.
point: If an IP works but a name fails, it is DNS.
point: ss -tlnp shows what is listening and on which address.
point: nc and curl test a port or service directly.
memory: Link, IP, gateway, remote, name, port.
card: Bottom-up network check order? => Link, IP address, gateway, remote IP, DNS, service port.
card: IP works but names fail? => DNS. Check resolv.conf or resolvectl status, test with dig.
card: What is listening, and which process? => ss -tlnp
card: Service on 127.0.0.1 only means? => It accepts local connections only. Bind it to 0.0.0.0 or the server IP.
card: Test a TCP port? => nc -zv host 443
card: Capture traffic to a file? => tcpdump -i eth0 -w file.pcap port 22
card: Hop-by-hop loss and latency? => mtr host
card: NIC speed and duplex? => ethtool eth0

@mc
Q: Which tcpdump command captures only SSH traffic on eth0 and writes it to ssh.pcap?
* tcpdump -i eth0 -w ssh.pcap port 22
- tcpdump eth0 port 22 > ssh.pcap
- tcpdump -i eth0 -o ssh.pcap 'ssh'
- tcpdump -c eth0 ssh -f ssh.pcap
E: -i picks the interface, -w writes a pcap file and port 22 is the capture filter.

@mc
Q: Which command lists all TCP listening sockets with the process that owns each one?
* ss -tlnp
- netstat -ano
- lsof -t tcp
- ip tcp show --listen
E: t is TCP, l is listening, n is numeric and p shows the process.

@mc
Q: Which command queries DNS for www.example.com and shows the answer and the server that replied?
* dig www.example.com
- nslookup -a www.example.com
- host --trace www.example.com
- ping -n www.example.com
E: dig shows the full question and answer, the TTL and which server answered. dig +trace follows the path from the root.

@mc
Q: Which command shows each hop to 8.8.8.8 and keeps measuring loss and latency per hop?
* mtr 8.8.8.8
- ping -r 8.8.8.8
- route trace 8.8.8.8
- ip route get 8.8.8.8
E: mtr combines ping and traceroute and updates continuously.

@mc
Q: Users report a server is unreachable. What is the best first network test from the server itself?
* Ping the default gateway
- Ping 8.8.8.8
- Run curl https://google.com
- Run dig google.com
E: Testing the gateway first separates local problems from upstream ones.

@mc
Q: Exhibit: $ ip -br a → eth0 UP 192.168.1.50/24 | $ ping -c1 192.168.1.1 → 1 received | $ ping -c1 8.8.8.8 → 1 received | $ ping google.com → Temporary failure in name resolution. What should be checked next?
* The DNS servers in /etc/resolv.conf or resolvectl status
- The network cable
- The default gateway
- The firewall rule for port 22
E: The link, address, gateway and internet all work. Only name lookups fail, so it is DNS.

@mc
Q: Which command checks whether TCP port 443 on 10.0.0.5 accepts connections?
* nc -zv 10.0.0.5 443
- ping -p 443 10.0.0.5
- dig 10.0.0.5:443
- arp 10.0.0.5 443
E: nc -z checks the port without sending data and -v reports the result. ping does not use ports.

@mc
Q: Which command shows only the HTTP status line and headers from a web server?
* curl -I https://intranet.example.com
- curl -O https://intranet.example.com
- wget --spider-body https://intranet.example.com
- dig https://intranet.example.com
E: -I sends a HEAD request and prints the headers, including the status code.

@mc
Q: Exhibit: $ ip route → 192.168.5.0/24 dev eth0 proto kernel | $ ping 8.8.8.8 → connect: Network is unreachable. What is wrong?
* There is no default route
- DNS is not set
- The interface is down
- The remote host is blocking ICMP
E: Only the local subnet is in the table. Add a default gateway with ip route add default via the router.

@mc
Q: Exhibit: $ ip link show eth0 → state DOWN. Which command brings the interface up?
* ip link set eth0 up
- ip addr up eth0
- ip route add eth0
- systemctl start eth0
E: ip link set up changes the link state. Then check that it gets an address.

@mc
Q: Two hosts may be using the same IP address. Which command checks for a duplicate before using 192.168.1.40?
* arping -D -I eth0 192.168.1.40
- ping -D 192.168.1.40
- ip neigh flush 192.168.1.40
- dig -x 192.168.1.40
E: arping -D does duplicate address detection. Any reply means another host already has the address.

@mc
Q: Small pings work over a VPN, but large file transfers hang. Which test checks for an MTU problem?
* ping -M do -s 1472 10.8.0.1
- ping -c 100 10.8.0.1
- traceroute -n 10.8.0.1
- ss -s
E: -M do forbids fragmentation and -s sets the size. If large sizes fail, lower the MTU.

@mc
Q: Exhibit: $ ss -tlnp | grep 8080 → LISTEN 127.0.0.1:8080 java. Remote users cannot reach the app. What is the fix?
* Configure the app to listen on 0.0.0.0 or the server's IP instead of 127.0.0.1
- Open port 8080 on the client
- Restart the network service
- Add 8080 to /etc/services
E: 127.0.0.1 accepts only local connections. The app must bind to an external address.

@mc
Q: Which command scans host 10.0.0.20 for open TCP ports 1 to 1000?
* nmap -p 1-1000 10.0.0.20
- ss -p 1-1000 10.0.0.20
- nc -l 1-1000 10.0.0.20
- ping -p 1000 10.0.0.20
E: nmap scans remote ports. Only scan systems you are allowed to test.

@mc
Q: A server's network is slow. Which command shows the NIC's negotiated speed and duplex?
* ethtool eth0
- ip route show eth0
- ifstat --speed eth0
- nmcli con up eth0
E: A link stuck at 100 Mb/s or half duplex often points to a bad cable or a switch port mismatch.

@order
Q: SIMULATION: A server cannot reach a website. Put these checks in bottom-up order.
- Check the link state with ip link
- Check the IP address with ip addr
- Ping the default gateway
- Ping a remote IP such as 8.8.8.8
- Test name resolution with dig
E: Each step proves the layer below it works, so you find the broken layer quickly.

@mc
Q: Which command shows packet error and drop counters for each interface?
* ip -s link
- ip route
- ip neigh
- ss -t
E: -s adds RX and TX statistics, including errors and drops.

## CONCEPT ts-storage | Storage and Filesystem Problems
idea: Storage problems show up as full disks, failing mounts or read-only filesystems. Read the exact error first.
point: No space left but df shows free space: check inodes with df -i.
point: Space not freed after deleting a log: a process still holds it open. Find it with lsof +L1.
point: Never run fsck on a mounted filesystem.
point: target is busy: find the user of the mount with lsof or fuser.
memory: df -h for blocks, df -i for inodes.
card: No space left but df -h shows space? => Out of inodes. Check df -i.
card: Deleted file still uses space? => A process holds it open. Find it with lsof +L1, restart that process.
card: Rule before running fsck? => Unmount the filesystem first.
card: Repair XFS? Repair ext4? => xfs_repair. e2fsck.
card: umount says target is busy? => fuser -vm /mount or lsof +D /mount.
card: Check drive health? => smartctl -a /dev/sda. A rising reallocated sector count means replace it.
card: Biggest folders first? => du -sh /path/* | sort -h
card: Add a disk to a degraded RAID? => mdadm --manage /dev/md0 --add /dev/sdd

@mc
Q: Before running fsck on /dev/sdb1, which step is required?
* Unmount the filesystem
- Run sync --force
- Remount it read-write
- Turn on quota checking
E: fsck on a mounted filesystem can corrupt it. Unmount it, or use -n for a read-only check.

@mc
Q: Which command reads the SMART data of /dev/sda to look for signs of drive failure?
* smartctl -a /dev/sda
- hdparm -I /dev/sda
- badblocks -w /dev/sda
- dmesg | grep sda
E: smartctl -a shows SMART attributes and self-test logs. badblocks -w overwrites the disk.

@mc
Q: Exhibit: touch: cannot touch 'file': No space left on device | $ df -h /var → 40% used | $ df -i /var → IUse% 100%. What is the cause?
* The filesystem has run out of inodes, usually from millions of tiny files
- The disk is failing
- The filesystem is mounted read-only
- The user has no write permission
E: Every file uses one inode. Find the folder with huge numbers of small files and clean it up.

@mc
Q: A 20 GB log was deleted, but df still shows the space as used. Which command finds the process holding it?
* lsof +L1
- du -sh /var/log
- find / -size +20G
- fsck -n /var
E: lsof +L1 lists open files with no links left, meaning deleted but still open. Restart that process to free the space.

@mc
Q: Which command shows which folders under /var use the most space, sorted by size?
* du -sh /var/* | sort -h
- df -h /var | sort
- ls -lS /var
- find /var -size -1G
E: du totals each folder and sort -h orders human-readable sizes.

@mc
Q: An XFS filesystem reports corruption. It has been unmounted. Which command repairs it?
* xfs_repair /dev/vg0/lv_data
- fsck.ext4 /dev/vg0/lv_data
- xfs_growfs /dev/vg0/lv_data
- e2fsck -y /dev/vg0/lv_data
E: XFS has its own repair tool. The e2fsck family is for ext filesystems.

@mc
Q: dmesg shows "EXT4-fs error ... Remounting filesystem read-only". What should be done?
* Stop writes, unmount the filesystem and run e2fsck, then check the disk health
- Remount it read-write and keep working
- Delete the journal
- Reboot repeatedly until it clears
E: The kernel made it read-only to protect the data. Repair it offline and check SMART for a failing disk.

@mc
Q: mount -t cifs fails with an error saying a helper program may be needed. What is the likely fix?
* Install the cifs-utils package
- Install nfs-utils
- Load the ext4 module
- Format the share
E: Mounting SMB shares needs mount.cifs from cifs-utils. NFS needs nfs-utils.

@mc
Q: /proc/mdstat shows md0 degraded with /dev/sdc marked failed. A new disk /dev/sdd is installed. Which command adds it so the array rebuilds?
* mdadm --manage /dev/md0 --add /dev/sdd
- mdadm --create /dev/md0 /dev/sdd
- mdadm --stop /dev/md0 --add /dev/sdd
- pvcreate /dev/sdd
E: --add puts the new disk in the array and the rebuild starts. Remove the failed disk with --remove first.

@mc
Q: umount /data fails with "target is busy". Which command shows what is using it?
* fuser -vm /data
- df -h /data
- mount -a /data
- blkid /data
E: fuser -m lists processes using the mount. lsof +D /data also works. A shell sitting inside the folder counts too.

@mc
Q: Exhibit: $ smartctl -A /dev/sdb → Reallocated_Sector_Ct 1 last week, 212 today. What should the administrator do?
* Back up the data and replace the disk soon
- Run fsck every day to fix the sectors
- Format the disk to reset the counter
- Ignore it, since the disk still works
E: A fast-rising reallocated sector count means the drive is failing. Get the data off first.

@match
Q: HOTSPOT: Match each storage error to the best fix.
- No space left, but df -h shows free space => Check inodes with df -i
- target is busy when unmounting => Find users with lsof or fuser
- ext4 superblock is damaged => Run e2fsck with a backup superblock
- Space not freed after deleting a large log => Restart the process holding it open
E: Each message points to a different cause, so read it closely before acting.

## CONCEPT ts-access | Access, Permission and Service Problems
idea: When something will not run or connect, check the service, its logs, file permissions and SELinux, in that order.
point: systemctl status and journalctl -u show why a service failed.
point: Address already in use means another process has the port.
point: Permission errors may come from mode bits, ownership, ACLs or SELinux.
point: cron runs with a minimal PATH. Use full paths in cron jobs.
memory: Status, logs, perms, context.
card: Why did a service fail? => systemctl status name, then journalctl -u name.
card: Address already in use? => Another process has the port. Find it with ss -tlnp.
card: Script gives Permission denied? => No execute bit. chmod +x script.
card: 403 with correct file permissions under SELinux? => Wrong context. restorecon -Rv /var/www/html.
card: bad interpreter: /bin/bash^M? => Windows line endings. Run dos2unix.
card: Script works by hand but not in cron? => cron's short PATH. Use full command paths.
card: Too many open files in a service? => Raise LimitNOFILE in the unit and restart.
card: Clear a pam_faillock lockout? => faillock --user name --reset

@mc
Q: An administrator wants to watch an Apache error.log in real time and also save what appears to another file for later. Which command does this?
- tail -f /var/log/apache2/error.log > logfile.txt
- tail -f /var/log/apache2/error.log | logfile.txt
- tail -f /var/log/apache2/error.log >> logfile.txt
* tail -f /var/log/apache2/error.log | tee logfile.txt
E: tee writes to the file and to the screen at the same time. Plain redirection hides the output.

@mc
Q: On a RHEL 9 server that keeps logs only in the systemd journal, which command shows new log entries live?
- tail -f /var/log/syslog
* journalctl -f
- dmesg -w only
- cat /var/log/messages | watch
E: journalctl -f follows the journal. /var/log/syslog is a Debian-family file, and dmesg shows only kernel messages.

@mc
Q: Running ./run.sh gives Permission denied. Exhibit: $ ls -l run.sh → -rw-r--r-- 1 ops ops 412 run.sh. What fixes it?
* chmod +x run.sh
- chown root run.sh
- setenforce 0
- mv run.sh /tmp
E: The file has no execute bit. Add it, or run it with bash run.sh.

@mc
Q: A web page returns 403 Forbidden. File permissions are 644 and the owner is correct. SELinux is enforcing. What is the most likely fix?
* restorecon -Rv /var/www/html
- chmod 777 /var/www/html
- systemctl restart firewalld
- Disable SELinux permanently
E: Files moved from a home folder keep the wrong SELinux type. restorecon gives them httpd_sys_content_t.

@mc
Q: A user gets "is not in the sudoers file. This incident will be reported." on RHEL. How should admin rights be granted?
* Add the user to the wheel group with usermod -aG wheel username
- Give the user the root password
- Run chmod 4755 /usr/bin/sudo
- Add the user to /etc/shadow
E: On RHEL the wheel group has sudo rights. On Debian and Ubuntu the group is sudo.

@mc
Q: A service will not start after a config change. What should the administrator check first?
* systemctl status app and journalctl -u app
- Reboot the server
- Reinstall the package
- Disable the firewall
E: The status output and unit logs usually name the exact error and line.

@mc
Q: Exhibit: $ systemctl status nginx → bind() to 0.0.0.0:80 failed (98: Address already in use). Which command finds the cause?
* ss -tlnp | grep ':80'
- ip route
- df -h
- chmod 644 /etc/nginx/nginx.conf
E: Another process already listens on port 80. ss -tlnp shows which one.

@mc
Q: A script copied from a Windows PC fails with "/bin/bash^M: bad interpreter". What fixes it?
* Convert the line endings with dos2unix script.sh
- chmod 777 script.sh
- Install bash again
- Rename the file to script.bat
E: Windows line endings add a carriage return (^M) to every line. dos2unix or sed -i 's/\r$//' removes it.

@mc
Q: The user bob is locked out after too many failed logins. Which command clears the pam_faillock counter?
* faillock --user bob --reset
- passwd -u bob
- usermod -U bob only
- chage -d 0 bob
E: faillock --reset clears the failure count kept by pam_faillock. passwd -u unlocks a password lock, which is a separate thing.

@mc
Q: A script works when run by hand but fails from cron with "command not found". What is the most likely cause?
* cron runs with a short PATH, so the script needs full command paths or its own PATH line
- cron cannot run Bash scripts
- The crontab file is read-only
- The system clock is wrong
E: cron's environment is minimal. Set PATH at the top of the crontab or use full paths like /usr/bin/rsync.

@mc
Q: An app fails with "Too many open files". Which change fixes it for a systemd service?
* Raise LimitNOFILE in the service's unit (or drop-in) and restart it
- Increase swap space
- Run chmod -R 777 on the app folder
- Lower the nice value
E: The open file limit is per process. For systemd services set LimitNOFILE. For shell sessions use ulimit -n.

@order
Q: SIMULATION: The app service failed after an update. Put the troubleshooting steps in order.
- Check the state with systemctl status app
- Read the logs with journalctl -u app
- Fix the config error the logs point to
- Restart the service with systemctl restart app
- Confirm it is listening with ss -tlnp
E: Find the error, fix it, restart, then prove it works from the outside view.
