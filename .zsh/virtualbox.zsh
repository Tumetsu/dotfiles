## virtualbox shortcuts

alias vbox-list-vms="vboxmanage list vms"
alias vbox-list-running="vboxmanage list runningvms"

function start-vagrant-ubuntu
{
    cd ~/VirtualBoxVMs/ubuntu
    vagrant up && vagrant ssh
}

function start-vagrant-arch
{
    cd ~/VirtualBoxVMs/archlinux
    vagrant up && vagrant ssh
}

function start-vagrant-kali
{
    cd ~/VirtualBoxVMs/kali
    vagrant up && vagrant ssh
}

function vbox-snapshot-vm
{
    local UUID=$1
    local SNAME=$2

    if [ -z $1 ] || [ -z $2 ]; then
        echo "Usage: $0 <uuid|vmname> <snapname>"
        echo "\nAvailable VMs:\n$(vbox-list-vms)"
        return 0
    fi
    vboxmanage snapshot $UUID take $SNAME
}

function vbox-list-snapshots
{
    local UUID=$1

    if [ -z $1 ]; then
        echo "Usage: $0 <uuid|vmname>"
        echo "\nAvailable VMs:\n$(vbox-list-vms)"
        return 0
    fi
    vboxmanage snapshot $UUID list --details
}

function vbox-restore-snapshot
{
    local UUID=$1
    local SNAPNAME=$2

    if [ -z $1 ]; then
        echo "Usage: $0 <uuid|vmname> <uuid|snapname>"
        echo "\nAvailable VMs:\n$(vbox-list-vms)"
        return 0
    fi
    vboxmanage snapshot $UUID restore $SNAPNAME
}

function vbox-show-vm-info
{
    local UUID=$1
    if [ -z $1 ]; then
        echo "Usage: $0 <uuid|vmname>"
        echo "\nAvailable VMs:\n$(vbox-list-vms)"
        return 0
    fi
    vboxmanage showvminfo $UUID
}
