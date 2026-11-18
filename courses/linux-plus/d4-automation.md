# MODULE automation | Automation, Orchestration and Scripting | Linux+ · Domain 4 (17%) | #6D28D9

## CONCEPT au-bash | Bash Scripting
idea: A Bash script is a list of commands with variables, tests and loops. Small scripts save hours of repeated work.
point: Start with #!/bin/bash and make it executable with chmod +x.
point: $1, $2 are arguments, $# counts them, $@ is all of them, $? is the last exit code.
point: Quote variables: "$var". Use ${var} when text follows the name.
point: > overwrites, >> appends, 2> sends errors, 2>&1 joins errors to output.
memory: $? is the question: did that last command work? 0 means yes.
card: First line of a Bash script? => #!/bin/bash
card: $#, $@, $0, $?? => Arg count, all args, script name, last exit code.
card: When do you need ${var}? => When text follows the name, like "${num}-file".
card: Capture a command's output? => var=$(command), with no spaces around =.
card: Send stdout and stderr to one file? => cmd > file 2>&1
card: Integer greater-than test? => [ "$n" -gt 10 ] (-lt, -eq, -ne, -ge, -le).
card: File test operators? => -f regular file, -d folder, -e exists, -r readable.
card: set -e, set -u, set -x? => Stop on error, error on unset vars, print each command.

@mc
Q: In a script, the line echo "profile-$num-$name" does not expand $num as expected. Which notation makes sure the value is expanded?
- echo "profile-$(num)-$name"
- echo 'profile-$num-$name'
- echo "profile-`num`-$name"
* echo "profile-${num}-$name"
E: Braces mark exactly where the variable name ends. $(num) would try to run a command named num, and single quotes stop all expansion.

@mc
Q: Which line must begin an executable script so it always runs with Bash?
* #!/bin/bash
- #bash
- #!/usr/bin/env shell
- #!/bin/sh --bash
E: The shebang line names the interpreter. #!/usr/bin/env bash also works.

@mc
Q: In Bash, which special variable holds the number of arguments passed to a script?
* $#
- $@
- $0
- $*
E: $# is the count. $@ and $* are the arguments themselves and $0 is the script name.

@mc
Q: Which Bash test is true when /etc/hosts exists and is a regular file?
* if [[ -f /etc/hosts ]]; then
- if [ -e /etc/hosts -t f ]; then
- if test /etc/hosts --file; then
- if [[ -r /etc/hosts -a -F ]]; then
E: -f tests for a regular file. -d tests for a directory and -e for anything that exists.

@mc
Q: Which Bash loop prints the numbers 1 to 5, one per line?
* for i in {1..5}; do echo $i; done
- for (i=1; i<=5; i++) { echo $i }
- foreach i in seq 1 5: echo $i
- loop i from 1 to 5; print i; end
E: Brace expansion {1..5} is the usual Bash way. for i in $(seq 1 5) also works.

@mc
Q: Which variable holds the exit status of the last command?
* $?
- $!
- $$
- $0
E: 0 means success and anything else means failure. $! is the PID of the last background job.

@mc
Q: A new script will not run and says Permission denied. Which command fixes it?
* chmod +x backup.sh
- chown root backup.sh
- bash -x backup.sh
- source +x backup.sh
E: The file needs execute permission. bash -x runs it with tracing but does not fix the permission.

@mc
Q: Which line asks the user for a name and stores it in the variable name?
* read -p "Name: " name
- input name
- echo "Name: " > name
- get name
E: read stores a line from standard input in a variable. -p shows a prompt.

@mc
Q: Which line stores today's date in YYYY-MM-DD format in the variable today?
* today=$(date +%F)
- today = $(date +%F)
- today=$date +%F
- set today date +%F
E: $( ) runs a command and captures its output. There must be no spaces around = in Bash.

@mc
Q: Which test checks whether the number in $count is greater than 10?
* if [ "$count" -gt 10 ]; then
- if [ "$count" > 10 ]; then
- if [ "$count" -greater 10 ]; then
- if ( $count gt 10 ); then
E: -gt compares integers. Inside [ ], > is treated as a redirect.

@mc
Q: Which keyword closes a case statement in Bash?
* esac
- endcase
- done
- fi
E: case closes with esac, if with fi, and loops with done.

@mc
Q: Which command sends only error messages from backup.sh to errors.log?
* ./backup.sh 2> errors.log
- ./backup.sh > errors.log
- ./backup.sh 1> errors.log
- ./backup.sh | errors.log
E: File descriptor 2 is standard error. 1 (or plain >) is standard output.

@mc
Q: Which command sends both normal output and errors from job.sh to job.log?
* ./job.sh > job.log 2>&1
- ./job.sh 2>&1 > job.log
- ./job.sh > job.log 1>&2
- ./job.sh 2> job.log 1>/dev/null
E: Redirect stdout to the file first, then point stderr at stdout. The other order sends errors to the terminal.

@mc
Q: Which loop reads servers.txt one line at a time into the variable line?
* while read -r line; do echo "$line"; done < servers.txt
- for line in read servers.txt; do echo $line; done
- while servers.txt; do read line; done
- until read line < servers.txt; done
E: Feed the file into the while loop with <. -r keeps backslashes as they are.

@mc
Q: What does set -e do near the top of a script?
* Makes the script stop when a command fails
- Prints each command before it runs
- Treats unset variables as errors
- Exports every variable
E: set -e exits on errors. set -x traces commands and set -u fails on unset variables.

@calc
Q: A script is run as ./backup.sh /data /mnt/usb daily. What is the value of $#?
A: 3
E: There are three arguments: /data, /mnt/usb and daily. The script name is $0 and is not counted.

@mc
Q: A script sets BACKUP_DIR and then calls another script that must see it. What must be done?
* export BACKUP_DIR
- local BACKUP_DIR
- readonly BACKUP_DIR
- unset BACKUP_DIR
E: export puts the variable in the environment of child processes. local limits it to a function.

@mc
Q: Which line correctly defines a Bash function named cleanup?
* cleanup() { rm -f /tmp/app.*; }
- function: cleanup { rm -f /tmp/app.* }
- def cleanup(): rm -f /tmp/app.*
- cleanup = { rm -f /tmp/app.* }
E: name() { commands; } is the standard form. The space after { and the ; before } are required on one line.

@match
Q: Match each special variable to what it holds.
- $0 => The name of the script
- $1 => The first argument
- $@ => All arguments as separate words
- $$ => The PID of the current shell
E: Quote "$@" when passing arguments on, so names with spaces stay whole.

## CONCEPT au-text | Text Processing and Regex
idea: sed, awk and grep turn raw logs and config files into exactly the lines you need.
point: grep finds lines. -i ignores case, -r searches folders, -v inverts, -E uses extended regex.
point: sed 's/old/new/g' replaces text. -i edits the file in place.
point: awk -F sets the separator. $1, $2 are fields.
point: ^ anchors the start of a line and $ the end.
memory: grep finds, sed changes, awk reports.
card: Replace text in a file in place? => sed -i 's/old/new/g' file
card: Print field 3 of a colon file? => awk -F: '{print $3}' file, or cut -d: -f1 for field 1.
card: grep -i, -r, -v, -E? => Ignore case, recursive, invert, extended regex.
card: Regex anchors? => ^ start of line, $ end of line.
card: Match one word or another? => grep -E 'WARN|ERROR' file
card: Uppercase text? => tr 'a-z' 'A-Z' < file
card: Count repeated lines? => sort file | uniq -c
card: Hide comment lines? => grep -v '^#' file

@mc
Q: Which command replaces every "http://" with "https://" in site.conf, saving the change in the file?
* sed -i 's|http://|https://|g' site.conf
- sed 's/http/https/' site.conf
- awk -i 's/http/https/g' site.conf
- grep -r http:// https:// site.conf
E: -i edits in place and g replaces every match on a line. Any character can be the separator, which avoids escaping slashes.

@mc
Q: Which command prints the UID column (field 3) of /etc/passwd?
* awk -F: '{print $3}' /etc/passwd
- awk '{print $3}' /etc/passwd
- cut -f3 /etc/passwd
- sed -n 3p /etc/passwd
E: /etc/passwd uses colons, so -F: is needed. sed -n 3p prints line 3, not field 3. (cut -d: -f3 also works.)

@mc
Q: Which command searches every file under /var/log for "error" in any letter case?
* grep -ri "error" /var/log
- grep -v "error" /var/log
- grep -c "error" /var/log
- find /var/log -name error
E: -r searches folders and -i ignores case. -v would show lines without the word.

@mc
Q: Which command shows a config file without comment lines that start with #?
* grep -v '^#' /etc/ssh/sshd_config
- grep '^#' /etc/ssh/sshd_config
- grep -c '#' /etc/ssh/sshd_config
- sed 's/#//' /etc/ssh/sshd_config
E: ^# matches lines that begin with # and -v hides them.

@mc
Q: Which lines does the regular expression ^root match?
* Lines that begin with root
- Lines that end with root
- Lines that contain root anywhere
- Lines that do not contain root
E: ^ anchors to the start of the line. root$ would match the end.

@mc
Q: Which command prints only the usernames from /etc/passwd?
* cut -d: -f1 /etc/passwd
- cut -f1 /etc/passwd
- head -1 /etc/passwd
- tr : -f1 /etc/passwd
E: -d: sets the colon as the separator and -f1 takes the first field.

@mc
Q: Which command converts the text in names.txt to uppercase?
* tr 'a-z' 'A-Z' < names.txt
- tr -u names.txt
- sed 'upper' names.txt
- awk -U names.txt
E: tr maps one set of characters to another. It reads standard input, so feed it the file.

@mc
Q: Which command shows lines in app.log that contain either WARN or ERROR?
* grep -E 'WARN|ERROR' app.log
- grep 'WARN' 'ERROR' app.log
- grep -v 'WARN|ERROR' app.log
- grep -x WARN,ERROR app.log
E: -E turns on extended regex, where | means or.

@match
Q: Match each tool to the job it does best.
- sed => Find and replace text in a stream or file
- awk => Pick out fields and build simple reports
- sort => Put lines in order
- uniq -c => Count repeated lines that sit together
E: Pipe them together, for example sort then uniq -c, to count occurrences.

## CONCEPT au-ansible | Ansible and Infrastructure as Code
idea: Configuration management describes how systems should look and applies it to many hosts the same way. Ansible does this over SSH with no agent.
point: The inventory lists hosts and groups. Playbooks are YAML lists of tasks.
point: Modules are idempotent: running twice gives the same result.
point: --check does a dry run. ansible-vault encrypts secrets. Handlers run only when notified.
point: Terraform builds infrastructure. cloud-init configures a new VM on first boot.
memory: Inventory says where. Playbook says what. Module says how.
card: Inventory vs playbook vs module? => Inventory: which hosts. Playbook: what to do. Module: how.
card: How does Ansible connect? => SSH, no agent on the nodes.
card: Test every host? => ansible all -m ping
card: Dry run a playbook? => ansible-playbook site.yml --check (add --diff).
card: Run on one group only? => ansible-playbook -i inv site.yml --limit web
card: Idempotent means? => Running again changes nothing once the system is right.
card: Encrypt secrets? Get roles? => ansible-vault. ansible-galaxy.
card: Run a task only when something changed? => A handler, triggered with notify.

@mc
Q: Which Ansible component contains a list of hosts and host groups?
- Fact
* Inventory
- Playbook
- Collection
E: The inventory tells Ansible which machines it manages and how they are grouped.

@mc
Q: Which Ansible ad-hoc command tests connectivity to every managed host with the ping module?
* ansible all -m ping
- ansible-playbook ping.yml -l all
- ansible-galaxy ping
- ansible-inventory --ping
E: ansible pattern -m module. The pattern all matches every host in the inventory.

@mc
Q: Which ansible-playbook option does a dry run and reports what would change without changing anything?
* --check
- --diff
- --dry-run
- --list-tasks
E: --check runs in check mode. Add --diff to see the exact changes.

@mc
Q: In a playbook, which task correctly makes sure the nginx package is installed?
* - name: Install nginx / apt: / name: nginx / state: present (each part on its own indented line)
- tasks: apt install nginx
- action: apt[name=nginx state=present]
- do: install nginx via apt
E: A task is a list item with a name and a module, and the module's arguments sit indented under it.

@mc
Q: Which command runs site.yml only against hosts in the web group, using inventory.ini?
* ansible-playbook -i inventory.ini site.yml --limit web
- ansible -i inventory.ini web site.yml
- ansible-playbook site.yml -m web
- ansible-galaxy run site.yml web
E: -i names the inventory and --limit narrows which hosts run.

@mc
Q: What does it mean that most Ansible modules are idempotent?
* Running the same task again makes no further change once the system is in the right state
- Each task runs only once and is then deleted
- Tasks run on every host at the same moment
- Tasks cannot fail
E: Idempotent tasks check the current state first, so repeat runs are safe.

@mc
Q: How does Ansible usually connect to Linux managed nodes?
* Over SSH, with no agent installed on the nodes
- Through an agent service on every node
- Over SNMP
- Through a VPN client it installs
E: Ansible is agentless. Python on the node and SSH access are enough.

@mc
Q: Which command downloads roles and collections from the community hub?
* ansible-galaxy
- ansible-vault
- ansible-doc
- ansible-pull
E: ansible-galaxy installs roles and collections. ansible-doc shows module help.

@mc
Q: A playbook needs a database password that must not sit in Git as plain text. Which tool protects it?
* ansible-vault
- ansible-galaxy
- ansible-inventory
- ansible-config
E: ansible-vault encrypts variable files. Playbooks decrypt them at run time with the vault password.

@mc
Q: A playbook should restart nginx only when its config file actually changes. Which feature fits?
* A handler triggered with notify
- A loop over every host
- A fact gathered at the start
- A tag on the task
E: Handlers run only when a task reports a change and notifies them.

@mc
Q: Which tool creates cloud infrastructure such as networks and VMs from declarative code?
* Terraform
- rsync
- cron
- logrotate
E: Terraform (or OpenTofu) is infrastructure as code. It plans changes and then applies them.

@mc
Q: Which configuration management tool normally relies on an agent installed on each managed node?
* Puppet
- Ansible
- Bash
- SSH
E: Puppet agents pull their config from a server. Ansible pushes over SSH with no agent.

@mc
Q: Which tool configures a new cloud VM on its first boot using user-data?
* cloud-init
- kickstart-gui
- systemd-firstboot only
- anacron
E: cloud-init reads user-data from the cloud platform to set users, keys, packages and scripts at first boot.

## CONCEPT au-git | Git and CI/CD
idea: Git tracks every change to scripts and config. CI/CD pipelines test and deploy those changes automatically.
point: clone, branch, add, commit, push, then open a pull request.
point: git pull is git fetch plus a merge.
point: .gitignore keeps secrets and build files out of the repo.
point: git revert undoes a shared commit safely. reset rewrites history.
memory: Add stages, commit saves, push shares.
card: Save changes as a commit? => git add, then git commit -m "message".
card: Create and switch to a branch? => git checkout -b name (or git switch -c name).
card: fetch vs pull? => fetch downloads. pull is fetch plus merge.
card: Undo a pushed commit safely? => git revert <hash>. Never force-push over shared history.
card: Keep files out of the repo? => .gitignore
card: See changed and staged files? => git status
card: CI vs CD? => CI builds and tests every change. CD releases changes that pass.
card: Share a branch for review? => git push origin branch, then open a pull request.

@mc
Q: A developer cloned a repo, edited files and wants to save a snapshot with the message fix typo. Which sequence is correct?
* git add . && git commit -m 'fix typo'
- git commit -a -m 'fix typo' && git push
- git save 'fix typo'
- git stage --all; git snapshot 'fix typo'
E: Stage the changes with git add, then commit them. git push uploads them later.

@mc
Q: Which command creates a new branch named feature and switches to it?
* git checkout -b feature
- git branch -d feature
- git merge feature
- git switch feature --delete
E: checkout -b creates and switches in one step. git switch -c feature does the same.

@mc
Q: Which command downloads new commits from the remote and merges them into the current branch?
* git pull
- git fetch
- git push
- git clone
E: pull is fetch plus merge. fetch only downloads.

@mc
Q: Which file stops Git from tracking .env files and the build/ folder?
* .gitignore
- .gitconfig
- .gitattributes
- .git/HEAD
E: Patterns in .gitignore are skipped by git add. Keep secrets out of repos this way.

@mc
Q: A bad commit was already pushed to the shared main branch. Which command undoes it safely for everyone?
* git revert <commit-hash>
- git reset --hard HEAD~1 && git push --force
- git rm <commit-hash>
- git checkout <commit-hash>
E: revert adds a new commit that undoes the change. Force-pushing a reset rewrites history other people already have.

@mc
Q: In a CI/CD pipeline, which part automatically builds and tests code each time a change is pushed?
* Continuous integration
- Continuous deployment
- Configuration drift
- Change advisory board
E: CI builds and tests every change. Continuous deployment then releases changes that pass.

@order
Q: SIMULATION: Put the steps to fix a script and propose the change in order.
- git clone the repository
- git checkout -b fix-backup
- Edit the script and run git add
- git commit -m "fix backup path"
- git push origin fix-backup
- Open a pull request for review
E: Work on a branch, commit, push the branch, then ask for review before merging.

@mc
Q: Which command shows which files are changed, staged or untracked?
* git status
- git log
- git show
- git remote -v
E: git status shows the working tree state. git log shows commit history.

## CONCEPT au-python-ai | Python and AI Best Practices
idea: Python handles automation that outgrows Bash. AI tools can help write scripts, but you check everything before it runs.
point: Use a virtual environment per project: python3 -m venv.
point: pip install -r requirements.txt installs a project's dependencies.
point: Never paste passwords, keys or private data into a public AI tool.
point: Read and test AI-written code in a safe place before production.
memory: AI drafts, you verify.
card: Create a Python virtual environment? => python3 -m venv .venv, then source .venv/bin/activate.
card: Install a project's dependencies? => pip install -r requirements.txt
card: Save the installed package list? => pip freeze > requirements.txt
card: How does Python 3 extend itself? => Modules and packages.
card: Before running an AI-written script? => Read it and test it on a non-production system.
card: What never goes into a public AI tool? => Passwords, keys, customer data and other secrets.
card: AI hallucination? => A confident answer that is wrong or made up.
card: Rule for AI output? => AI drafts, you verify.

@mc
Q: Which of the following is a characteristic of Python 3?
- It is closed source.
* It is extensible through modules.
- It is fully backwards compatible.
- It is binary compatible with Java.
E: Python 3 is open source and grows through modules and packages. It is not fully compatible with Python 2.

@mc
Q: Which command creates an isolated Python environment in the folder .venv?
* python3 -m venv .venv
- pip install venv .venv
- python3 --isolate .venv
- virtualenv-remove .venv
E: The venv module creates the environment. Activate it with source .venv/bin/activate.

@mc
Q: Which command installs every dependency listed by a Python project?
* pip install -r requirements.txt
- pip freeze requirements.txt
- python3 requirements.txt
- pip list -r requirements.txt
E: -r reads package names from the file. pip freeze writes the installed list out.

@mc
Q: Which pip command installs the requests package inside the active virtual environment?
* pip install requests
- pip get requests
- python3 -m requests install
- dnf pip requests
E: With the venv active, pip installs into it and not into the system Python.

@mc
Q: An AI assistant wrote a Bash script that deletes old files. What should the administrator do before running it on production servers?
* Read it line by line and test it on a non-production system
- Run it right away with sudo
- Run it on production first and watch the logs
- Ask the AI if the script is safe and trust the answer
E: AI output can be wrong but sound sure. Review and test it like any untrusted script.

@mc
Q: An admin wants help fixing a config file from a public AI chatbot. What must be removed first?
* Passwords, API keys and other secrets in the file
- The comments
- The blank lines
- The file name
E: Public AI tools may keep prompts. Strip secrets and private data, or use an approved private tool.
