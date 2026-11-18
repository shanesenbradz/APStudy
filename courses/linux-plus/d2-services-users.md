# MODULE services | Services and User Management | Linux+ · Domain 2 (20%) | #0F766E

## CONCEPT su-systemd | systemd Services and Timers
idea: systemd starts and watches services. Each service is a unit file, and systemctl is the remote control.
point: enable sets start at boot. start runs it now. enable --now does both.
point: After editing a unit file, run systemctl daemon-reload.
point: systemctl edit makes a drop-in override so package updates do not wipe your change.
point: mask blocks a unit completely. Timers (.timer units) can replace cron jobs.
memory: Edit, daemon-reload, restart. Every time.
card: Enable and start a service in one command? => systemctl enable --now name
card: Run after editing a unit file? => systemctl daemon-reload
card: Override a packaged unit safely? => systemctl edit name (makes a drop-in in /etc/systemd/system/name.service.d/).
card: disable vs mask? => disable stops boot start. mask blocks the unit from starting at all.
card: Boot to text mode by default? => systemctl set-default multi-user.target
card: is-enabled vs is-active? => is-enabled: starts at boot? is-active: running now?
card: List failed units? => systemctl --failed
card: systemd's replacement for cron jobs? => .timer units, with OnCalendar= for the schedule.

@mc
Q: Which command enables the sshd service to start at boot and also starts it right now?
* systemctl enable --now sshd
- systemctl start --enable sshd
- chkconfig sshd on && service sshd start
- systemctl preset sshd.service
E: enable --now combines enable (start at boot) and start (start now).

@mc
Q: Which command checks whether the nginx service is set to start at boot?
* systemctl is-enabled nginx
- systemctl is-active nginx
- systemctl show-boot nginx
- service nginx enabled
E: is-enabled reports the boot setting. is-active reports whether it is running right now.

@mc
Q: An administrator edited /etc/systemd/system/app.service. What must be run before restarting the service?
* systemctl daemon-reload
- systemctl reset-failed
- systemctl reload app
- systemctl isolate app
E: daemon-reload makes systemd read changed unit files. Without it the old definition is still used.

@mc
Q: What is the best way to change one setting in a unit file shipped by a package so updates do not overwrite it?
* systemctl edit nginx
- Edit /usr/lib/systemd/system/nginx.service directly
- Copy the file to /tmp and point systemd at it
- Add the setting to /etc/fstab
E: systemctl edit creates a drop-in file under /etc/systemd/system/nginx.service.d/ that overrides only what you change.

@mc
Q: A service must not be started by anyone, including other services that depend on it. Which command does this?
* systemctl mask cups
- systemctl disable cups
- systemctl stop cups
- systemctl kill cups
E: mask links the unit to /dev/null so it cannot start at all. disable only stops it starting at boot.

@mc
Q: A server should boot to a text console with networking instead of a desktop. Which command sets this?
* systemctl set-default multi-user.target
- systemctl set-default graphical.target
- systemctl isolate rescue.target
- systemctl default emergency.target
E: multi-user.target is the normal non-graphical target. isolate changes the current state but not the default.

@match
Q: HOTSPOT: Match each unit file directive to what it does.
- ExecStart= => The command that starts the service
- After= => Start this unit only after the named units
- WantedBy= => The target that pulls it in when enabled
- Restart= => When systemd restarts it automatically
E: ExecStart and Restart go in [Service]. After goes in [Unit]. WantedBy goes in [Install].

@mc
Q: Which systemd unit type can replace a cron job?
* .timer
- .socket
- .mount
- .path
E: A .timer unit starts a matching .service unit on a schedule.

@mc
Q: Which command lists only the units that have failed?
* systemctl --failed
- systemctl list-units --all
- journalctl --failed
- systemctl status --broken
E: systemctl --failed (or list-units --state=failed) shows every unit in the failed state.

@order
Q: SIMULATION: A custom app needs to run as a service and start at boot. Put the steps in order.
- Write the unit file /etc/systemd/system/app.service
- Run systemctl daemon-reload
- Run systemctl enable --now app
- Check it with systemctl status app
E: Create the unit, let systemd read it, enable and start it, then confirm it is running.

@tf
Q: systemctl reload always stops and starts the service process.
A: false
E: reload asks the service to re-read its config without stopping, if the service supports it. restart stops and starts it.

@mc
Q: Which timer setting runs the matching service every day at 2:00 AM?
* OnCalendar=*-*-* 02:00:00
- OnBootSec=2h
- OnCalendar=02 * * * *
- OnUnitActiveSec=2am
E: OnCalendar uses the year-month-day hour:minute:second format. The cron-style line is not valid in a timer.

## CONCEPT su-users | Users, Groups and Accounts
idea: Every user has a line in /etc/passwd and a password hash in /etc/shadow. Groups give shared access.
point: useradd -m makes a home directory. -s sets the shell. Files from /etc/skel are copied in.
point: usermod -aG adds a supplementary group. Without -a the user is removed from other groups.
point: chage sets password age and account expiry.
point: getent reads users and groups from every source, including LDAP.
memory: -aG: Always Append Groups.
card: Add a user to a group without dropping others? => usermod -aG group user
card: Create a user with a home folder and bash? => useradd -m -s /bin/bash name
card: Where are password hashes? => /etc/shadow (root only).
card: /etc/passwd fields? => Name, x, UID, GID, comment, home, shell.
card: Files copied into every new home folder? => /etc/skel
card: Set max password age? Account expiry? => chage -M 90 user. chage -E 2026-12-31 user.
card: Lock and remove a user? => Lock: passwd -l user. Remove with home: userdel -r user.
card: Look up a user from every source, LDAP included? => getent passwd user

@mc
Q: An administrator needs to check the user ID, home directory and shell of the user accounting. Which command should be used?
* getent passwd accounting
- id accounting
- grep accounting /etc/shadow
- who accounting
E: getent passwd returns the full account entry, including UID, GID, home directory and shell. id shows only IDs and groups.

@mc
Q: A Linux administrator wants to add a user to the docker group without changing their primary group. Which command should be used?
* sudo usermod -aG docker user
- sudo groupmod docker user
- sudo usermod -g docker user
- sudo groupmod -G docker user
E: -a appends and -G names a supplementary group. -g would change the primary group.

@mc
Q: Which command locks the account contractor by putting an exclamation mark in front of its password hash?
* passwd -l contractor
- chage -l contractor
- userdel -l contractor
- passwd -S contractor
E: passwd -l locks the password. chage -l lists ageing info and passwd -S shows status.

@mc
Q: Which command forces the user dbadmin to change password every 90 days?
* chage -M 90 dbadmin
- passwd -m 90 dbadmin
- usermod --passmax 90 dbadmin
- chage --days 90 dbadmin
E: chage -M sets the maximum password age in days.

@mc
Q: Which command creates the user alice with a home directory and bash as her shell?
* useradd -m -s /bin/bash alice
- useradd -d -b /bin/bash alice
- adduser -s alice /bin/bash
- usermod -m -s /bin/bash alice
E: -m creates the home directory and -s sets the login shell. usermod changes an existing user.

@mc
Q: Which file stores user password hashes?
* /etc/shadow
- /etc/passwd
- /etc/group
- /etc/login.defs
E: /etc/shadow holds hashes and is readable only by root. /etc/passwd shows an x in the password field.

@mc
Q: Every new user should get a standard .bashrc. Where should the administrator put it?
* /etc/skel
- /etc/profile.d
- /root
- /usr/share/bash
E: useradd -m copies everything in /etc/skel into the new home directory.

@mc
Q: Which command changes bob's login shell to /bin/zsh?
* usermod -s /bin/zsh bob
- usermod -d /bin/zsh bob
- useradd -s /bin/zsh bob
- passwd -s /bin/zsh bob
E: usermod -s changes the shell of an existing account. chsh -s /bin/zsh bob also works.

@mc
Q: An employee left. Which command removes their account and home directory?
* userdel -r jsmith
- userdel jsmith
- usermod -L jsmith
- deluser --keep-home jsmith
E: userdel -r removes the home directory and mail spool too. Without -r the files stay.

@match
Q: Match each field number in /etc/passwd to what it holds.
- Field 1 => Username
- Field 3 => UID
- Field 6 => Home directory
- Field 7 => Login shell
E: The fields are name, password placeholder, UID, GID, comment, home and shell.

@mc
Q: Which command creates a new group named developers?
* groupadd developers
- useradd -g developers
- groupmod developers
- newgrp developers
E: groupadd makes the group. newgrp switches your current group for a session.

@mc
Q: Which TWO commands show the groups that dave belongs to? (Choose two.)
* id dave
* groups dave
- who dave
- last dave
E: id lists UID, GID and groups. groups lists group names. who and last show sessions.

@mc
Q: A contractor's account must stop working on 31 December 2026. Which command sets this?
* chage -E 2026-12-31 contractor
- chage -M 2026-12-31 contractor
- passwd -x 2026-12-31 contractor
- usermod -L 2026-12-31 contractor
E: chage -E sets the account expiry date. -M sets maximum password age in days.

@calc
Q: On RHEL and Ubuntu, what is the first UID normally given to a regular (non-system) user?
A: 1000
E: UIDs below 1000 are reserved for system accounts. UID_MIN in /etc/login.defs sets this.

@mc
Q: Which command shows who is logged in and what each user is running?
* w
- whoami
- id
- last
E: w shows logged-in users and their current command. last shows login history.

## CONCEPT su-processes | Processes and Scheduling
idea: Every program is a process with a PID. You can watch it, change its priority, signal it, or schedule it to run later.
point: kill sends signal 15 (TERM) by default. kill -9 forces it.
point: nice sets priority at start, renice changes it later. Higher nice means lower priority.
point: cron runs jobs on a schedule. at runs a job once.
point: Background jobs: command &, jobs, fg, bg. nohup keeps a job alive after logout.
memory: Nice people go last: higher nice, lower priority.
card: Default kill signal? Force signal? => 15 (SIGTERM). 9 (SIGKILL), which cannot be caught.
card: Nice range and which is lowest priority? => -20 to 19. 19 is lowest priority.
card: nice vs renice? => nice sets priority when starting. renice changes a running process.
card: Crontab field order? => Minute, hour, day of month, month, day of week.
card: cron vs at? => cron repeats on a schedule. at runs once.
card: Keep a job running after logout? => nohup command &
card: Bring job 1 to the foreground? Resume in background? => fg %1. bg %1.
card: Find PIDs by name? Signal by name? => pgrep name. pkill name (or killall name).

@mc
Q: Which crontab line runs /opt/backup.sh at 2:00 AM every Sunday?
* 0 2 * * 0 /opt/backup.sh
- 2 0 * * 7 /opt/backup.sh
- 0 2 0 * * /opt/backup.sh
- * * 0 2 * /opt/backup.sh
E: The fields are minute, hour, day of month, month, day of week. Day of week 0 (or 7) is Sunday.

@mc
Q: A process with PID 4321 ignores a normal kill. Which command forces it to stop?
* kill -9 4321
- kill -15 4321
- kill -1 4321
- kill -0 4321
E: Signal 9 (SIGKILL) cannot be caught or ignored. 15 is the polite default and 1 is hangup.

@mc
Q: A long report job should run with the lowest CPU priority. Which command starts it that way?
* nice -n 19 ./report.sh
- nice -n -20 ./report.sh
- renice 19 ./report.sh
- chrt -p 0 ./report.sh
E: Nice 19 is the lowest priority. -20 is the highest and needs root.

@mc
Q: Which command lowers the priority of the running process 1234?
* renice -n 10 -p 1234
- nice -n 10 1234
- kill -n 10 1234
- top -p 1234 -n 10
E: renice changes the nice value of a running process. nice only works when starting one.

@mc
Q: A command must run once tonight at 11 PM. Which tool fits best?
* at 23:00
- crontab -e
- systemctl start --at 23:00
- batch -t 2300
E: at schedules a one-time job. cron is for repeating jobs.

@mc
Q: A long copy must keep running after the administrator logs out of SSH. Which command fits?
* nohup cp -r /data /backup &
- cp -r /data /backup &
- fg cp -r /data /backup
- jobs cp -r /data /backup
E: nohup ignores the hangup signal sent at logout. A plain & job can be killed when the session ends.

@mc
Q: A job was sent to the background with &. Which command brings job 1 back to the foreground?
* fg %1
- bg %1
- jobs -f 1
- kill -CONT 1
E: fg brings a job to the foreground. bg resumes a stopped job in the background.

@match
Q: Match each signal to what it does.
- SIGHUP (1) => Hangup, many daemons reload their config
- SIGKILL (9) => Ends the process and cannot be caught
- SIGTERM (15) => Asks the process to end cleanly
- SIGSTOP (19) => Pauses the process
E: Try SIGTERM first so the program can clean up. Use SIGKILL only when it will not stop.

@calc
Q: A crontab entry starts with */15 * * * *. How many times does it run each hour?
A: 4
U: times
E: */15 in the minute field means minutes 0, 15, 30 and 45.

@mc
Q: Which command prints the PIDs of every process named nginx?
* pgrep nginx
- pkill nginx
- ps -p nginx
- pidof -k nginx
E: pgrep finds PIDs by name. pkill sends a signal by name.

@mc
Q: Which command sends SIGTERM to every process named httpd?
* pkill httpd
- pgrep httpd
- kill httpd
- killall -l httpd
E: pkill (or killall httpd) signals by name. kill needs a PID and killall -l only lists signal names.

## CONCEPT su-logging | Logging and Time
idea: journald collects logs from the kernel and services. rsyslog can write them to files or send them to a central server. Accurate time keeps logs in order.
point: journalctl -u unit, -b this boot, -p err priority, -f follow.
point: Make the journal persistent with /var/log/journal or Storage=persistent.
point: logrotate stops logs from filling the disk.
point: chrony keeps time in sync. timedatectl sets the time zone.
memory: journalctl filters: u for unit, b for boot, p for priority, f for follow.
card: Follow a unit's logs live? => journalctl -u name -f
card: Errors and worse since this boot? => journalctl -b -p err
card: Logs from the previous boot? => journalctl -b -1 (needs persistent journal).
card: Make the journal persistent? => Storage=persistent in journald.conf, or create /var/log/journal.
card: rsyslog forward over TCP vs UDP? => @@host:514 is TCP. @host:514 is UDP.
card: Where do custom logrotate rules go? => /etc/logrotate.d/
card: Check NTP sources? Clock offset? => chronyc sources. chronyc tracking.
card: Set the time zone? => timedatectl set-timezone America/Jamaica

@mc
Q: Which of the following best describes journald?
* A system service that collects and stores logging data
- A feature that creates crash dumps if the kernel fails
- A service that keeps the filesystem journal
- A service that writes audit records to disk
E: systemd-journald gathers logs from the kernel, early boot and services into a structured journal.

@mc
Q: Which command follows new log entries for the nginx service in real time?
* journalctl -u nginx -f
- journalctl -f /var/log/nginx
- systemctl logs nginx --follow
- dmesg -u nginx
E: -u selects the unit and -f follows new entries.

@mc
Q: Which chrony command shows the configured NTP sources and their state?
* chronyc sources
- chronyd -q
- timedatectl ntp
- ntpq -c peers
E: chronyc sources asks the local chronyd for each source and how well it is reachable.

@mc
Q: Which command shows only error-level messages and worse since the current boot?
* journalctl -b -p err
- journalctl -k -f
- journalctl --since err
- dmesg -b err
E: -b limits to this boot and -p err shows priority err and above.

@mc
Q: Journal logs disappear after each reboot. What makes them persistent?
* Set Storage=persistent in /etc/systemd/journald.conf (or create /var/log/journal) and restart journald
- Run journalctl --flush every hour from cron
- Delete /run/log/journal
- Install logrotate
E: With volatile storage the journal lives in /run, which is cleared at boot. Persistent storage writes to /var/log/journal.

@mc
Q: Where should a custom rotation policy for an app's logs be placed?
* /etc/logrotate.d/
- /etc/rsyslog.d/
- /var/log/rotate/
- /etc/systemd/journald.conf.d/
E: logrotate reads its main file and every file in /etc/logrotate.d/.

@mc
Q: Which rsyslog rule sends all messages to 10.0.0.9 over TCP?
* *.* @@10.0.0.9:514
- *.* @10.0.0.9:514
- *.* >>10.0.0.9:514
- *.* tcp://10.0.0.9:514
E: Two @ signs mean TCP. One @ means UDP.

@mc
Q: Which command sets the system time zone to America/Jamaica?
* timedatectl set-timezone America/Jamaica
- date --zone America/Jamaica
- hwclock --tz America/Jamaica
- localectl set-timezone America/Jamaica
E: timedatectl manages time, time zone and NTP. localectl handles language and keyboard.

@mc
Q: Which command shows how much disk space the systemd journal is using?
* journalctl --disk-usage
- du -sh /var/log/messages
- journalctl --vacuum-size
- df -h /run/log
E: --disk-usage reports the total. --vacuum-size removes old entries down to a size.

@mc
Q: A Bash script must write a message into the system log. Which command does this?
* logger "backup finished"
- echo "backup finished" > /dev/log
- journalctl -w "backup finished"
- syslog "backup finished"
E: logger sends a message to the system logger, which journald and rsyslog then store.

@mc
Q: Which command shows how far the local clock is from its NTP source?
* chronyc tracking
- timedatectl list-timezones
- hwclock --show
- date -u
E: chronyc tracking shows the selected source, the offset and the frequency error.

## CONCEPT su-containers | Containers
idea: A container packs an app with what it needs and shares the host kernel. Images are templates. Containers are running copies.
point: docker run creates and starts. -d runs in the background, -p maps ports, -v mounts storage.
point: docker exec -it runs a shell in a container that is already running.
point: Podman runs containers without a daemon and can run rootless.
point: A Dockerfile starts with FROM. docker compose runs several containers from one file.
memory: run makes new. exec goes inside. logs tells you why it died.
card: Download an image? => docker pull debian (names are lowercase).
card: Create and start a new container? => docker run. -d background, -p host:container ports, -v storage, --name.
card: Open a shell in a running container? => docker exec -it name /bin/bash
card: List all containers, stopped too? => docker ps -a
card: Why did a container exit? => docker logs name
card: Build an image from a Dockerfile? => docker build -t name:tag .
card: Daemonless, rootless Docker alternative? => Podman.
card: Start every service in compose.yaml? => docker compose up -d

@mc
Q: A Linux user needs to download the latest Debian image from a Docker registry. Which command does this?
* docker image pull debian
- docker image init debian
- docker image import debian
- docker image save debian
E: pull downloads an image. Image names are lowercase, so debian, not Debian. save exports an image to a tar file.

@mc
Q: A Linux administrator needs to create and then connect to a container from app-01-image. Which command does this?
* docker run -it app-01-image
- docker start -td app-01-image
- docker build -ic app-01-image
- docker exec -dc app-01-image
E: docker run creates and starts a container. -it gives an interactive terminal.

@mc
Q: Which command lists all containers on a Docker host, including stopped ones?
* docker ps -a
- docker ls --all
- docker container list --stopped
- docker images -a
E: docker ps -a shows running and exited containers. docker images lists images.

@mc
Q: Which command starts an nginx container in the background, maps host port 8080 to container port 80, and names it web?
* docker run -d --name web -p 8080:80 nginx
- docker start -b web -p 8080:80 nginx
- docker create web:8080:80 nginx
- docker run -it web --port 8080:80 nginx
E: -d detaches, --name names it, and -p maps host:container.

@mc
Q: Which command builds an image tagged myapp:1.0 from the Dockerfile in the current directory?
* docker build -t myapp:1.0 .
- docker make -t myapp:1.0 .
- docker image create myapp:1.0
- docker compile -f Dockerfile -t myapp
E: docker build -t tag context. The dot uses the current directory.

@mc
Q: Which command opens a bash shell inside the running container web?
* docker exec -it web /bin/bash
- docker run -it web /bin/bash
- docker attach --shell web
- docker start -i web bash
E: exec runs a new command in a running container. run would create a new container.

@mc
Q: A team wants to run containers without a root daemon and as normal users. Which tool fits?
* Podman
- Docker Engine with the default daemon
- containerd shim
- LXD as root
E: Podman is daemonless and supports rootless containers. Its commands match Docker's.

@mc
Q: A container must store its data in /srv/data on the host so the data survives when the container is removed. Which option does this?
* docker run -v /srv/data:/data myapp
- docker run -p /srv/data:/data myapp
- docker run --env /srv/data myapp
- docker run --tmpfs /srv/data myapp
E: -v host_path:container_path bind-mounts host storage. tmpfs lives in memory and is lost.

@mc
Q: A container exits right after starting. Which command shows its output to find out why?
* docker logs web
- docker inspect --logs web
- journalctl -u web
- docker top web
E: docker logs shows what the container wrote to stdout and stderr.

@mc
Q: Which command removes images that no container uses?
* docker image prune
- docker rmi --all-running
- docker system df
- docker image ls -q
E: prune removes dangling images. Add -a to remove every unused image.

@mc
Q: Which Dockerfile instruction sets the base image?
* FROM
- RUN
- BASE
- IMAGE
E: Every Dockerfile starts with FROM, for example FROM ubuntu:24.04.

@order
Q: SIMULATION: Put these Dockerfile lines in a working order for an nginx image.
- FROM ubuntu:24.04
- RUN apt-get update && apt-get install -y nginx
- COPY site/ /var/www/html/
- EXPOSE 80
- CMD ["nginx", "-g", "daemon off;"]
E: Start from a base, install software, copy in content, document the port, and set the default command last.

@mc
Q: Which command starts every service defined in compose.yaml in the background?
* docker compose up -d
- docker compose build
- docker run --compose -d
- docker compose start --all
E: up creates and starts the services. -d detaches.

@mc
Q: Which command shows a container's full configuration, including its IP address and mounts?
* docker inspect web
- docker ps web
- docker stats web
- docker port --all web
E: docker inspect prints the full JSON configuration.

@mc
Q: The image app:1.0 was tagged as registry.example.com/app:1.0. Which command uploads it to that registry?
* docker push registry.example.com/app:1.0
- docker pull registry.example.com/app:1.0
- docker save registry.example.com/app:1.0
- docker commit registry.example.com/app:1.0
E: push uploads to a registry. pull downloads and save writes a local tar file.
