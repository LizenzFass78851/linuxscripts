#!/bin/bash

set -e

# -------------------------------------------------------------------------------------------------
change_apt_sources() {
    local mirror_url=$1
    local source_list=$2
    sed -i "s|http://archive.ubuntu.com/ubuntu|$mirror_url|g" $source_list
    sed -i "s|http://security.ubuntu.com/ubuntu|$mirror_url|g" $source_list
}

update_and_upgrade() {
    apt update
    apt dist-upgrade -y
    apt autopurge -y
}

change_timezone() {
    local timezone=$1
    timedatectl set-timezone $timezone
}

install_language() {
    local language=$1
    local language_long=$2
    apt install -y language-pack-$language
    update-locale LANG=${language_long}.UTF-8
}

install_fail2ban() {
    local jaillocal=/etc/fail2ban/jail.local
    apt install -y fail2ban
    cp /etc/fail2ban/jail.conf $jaillocal
    systemctl start fail2ban
    systemctl enable fail2ban
    sed -i "s/^banaction =.*$/banaction = nftables-multiport/g" $jaillocal
    sed -i "s/^banaction_allports =.*$/banaction_allports = nftables-allports/g" $jaillocal
    systemctl restart fail2ban
}

remove_snapd() {
    apt purge -y snapd
    echo -e "Package: snapd\nPin: release *\nPin-Priority: -1" | sudo tee /etc/apt/preferences.d/no-snap
    apt autoremove -y
    apt update
}

setup_mozilla_mirror() {
    install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | sudo tee /etc/apt/preferences.d/mozilla
    echo 'Unattended-Upgrade::Allowed-Origins:: "packages.mozilla.org:mozilla";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
    apt update
}

create_ipv6_disable_service() {
    bash -c 'cat <<EOF > /etc/systemd/system/disable-ipv6.service
[Unit]
Description=Disable IPv6

[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6"

[Install]
WantedBy=multi-user.target
EOF'

    bash -c 'cat <<EOF > /etc/systemd/system/disable-ipv6.timer
[Unit]
Description=Run disable-ipv6.service every 12 hours

[Timer]
OnCalendar=*-*-* *:00/12:00
Persistent=true

[Install]
WantedBy=timers.target
EOF'

    systemctl daemon-reload
    systemctl enable disable-ipv6.service
    systemctl enable disable-ipv6.timer
    systemctl start disable-ipv6.timer
    systemctl start disable-ipv6.service
}

create_journal_cleanup_service() {
    bash -c 'cat <<EOF > /etc/systemd/system/cleanup-journal.service
[Unit]
Description=Clean up journal logs older than one week

[Service]
Type=oneshot
ExecStart=/usr/bin/journalctl --vacuum-time=1weeks

[Install]
WantedBy=multi-user.target
EOF'

    bash -c 'cat <<EOF > /etc/systemd/system/cleanup-journal.timer
[Unit]
Description=Run cleanup-journal.service daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF'

    systemctl daemon-reload
    systemctl enable cleanup-journal.service
    systemctl enable cleanup-journal.timer
    systemctl start cleanup-journal.timer
    systemctl start cleanup-journal.service
}

create_user() {
    local username=$1
    local userid=$2
    local password=$3
    useradd -m -u $userid -s /bin/bash $username
    echo "$username:$password" | chpasswd
}

create_hushlogin() {
    touch ~/.hushlogin
}

change_hostname() {
    local hostname=$1
    echo ${hostname} > /etc/hostname
}

# -------------------------------------------------------------------------------------------------
main() {
    update_and_upgrade
    change_apt_sources "http://aptmirror.example.invalid" "/etc/apt/sources.list.d/ubuntu.sources"
    change_timezone "Europe/Berlin"
    install_language "de" "de_DE"
    install_fail2ban
    remove_snapd
    setup_mozilla_mirror
    create_ipv6_disable_service
    create_journal_cleanup_service
    create_user "nonrootuser" 1501 "yourpassword"
    create_hushlogin
    change_hostname "srv-examplename" #maximum 15 characters long
}
# -------------------------------------------------------------------------------------------------

main
