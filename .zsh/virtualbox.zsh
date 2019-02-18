## virtualbox shortcuts

alias vbox-list-vms="vboxmanage list vms"
alias vbox-list-running="vboxmanage list runningvms"

function _list_vbox_vms_name
{
    vboxmanage list vms|awk -F'"' '{print $2}'
}

function _list_vbox_vms_uuid
{
    vboxmanage list vms|awk '{print $2}'
}

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

function start-vagrant-centos
{
    cd ~/VirtualBoxVMs/centos
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
compdef '_arguments "1: :($(_list_vbox_vms_name))"' vbox-snapshot-vm


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
compdef '_arguments "1: :($(_list_vbox_vms_name))"' vbox-list-snapshots

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
compdef '_arguments "1: :($(_list_vbox_vms_name))"' vbox-show-vm-info

