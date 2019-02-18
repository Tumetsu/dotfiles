#!/usr/bin/env bash
#
# WARNING:
#   The following script is not finished and can't work for everyone.
#   Please check the script before blindly executing it!
#   Also the script assumes you are running x64 architecture (we are in 21st century)
#
# Script to run inside the arch-chroot
# Example: arch-chroot /mnt /sysprep_archlinux_chroot.sh /dev/sda2 /dev/mapper/root
#

## stop the planet from spinning when an error occurs
# set -e

if [ "$BASH_VERSION" = '' ] && [ ! $(grep -aq bash /proc/$$/cmdline) ]; then
    echo "This script must be run in bash !!!"
    echo "If running with another shell it may cause unespected behaviour ..."
    return 1
fi

echo "$(tput setaf 2)[+] Information required for the chroot environment$(tput sgr0)";
read -p "$(tput setaf 2) [?] Enter hostname:$(tput sgr0)                                              " tmp_HOSTNAME
read -p "$(tput setaf 2) [?] Enter username:$(tput sgr0)                                              " tmp_USERNAME
read -p "$(tput setaf 2) [?] Boot loader to install ([grub] OR [default: systemd-boot] ):$(tput sgr0) " tmp_BOOT_TYPE
read -p "$(tput setaf 2) [?] Swap file size (default: 2G):$(tput sgr0)                                " tmp_SWAP_SIZE
read -p "$(tput setaf 2) [?] Locales to use for the system (default: fr_CH-latin1):$(tput sgr0)       " tmp_LOCALES

## if using nvme change the names
if ls /dev/nvme0n2 &>/dev/null; then
    PARTITION2=${1:-"/dev/nvme0n2"}
else
    PARTITION2=${1:-"/dev/sda2"}
fi

## if there is no encryption we should use
## the second partition /dev/[sda2|nvme0n2]
SHOULD_ENCRYPT_DISK=${2:-"Y"}
if [[ $SHOULD_ENCRYPT_DISK =~ [Yy] ]]; then
    PARTITION_LUKS=${3:-"/dev/mapper/root"}
else
    PARTITION_LUKS=${PARTITION2}
fi

HOSTNAME=${tmp_HOSTNAME:-"archhostname"}
USERNAME=${tmp_USERNAME:-"boogy"}
BOOT_TYPE=${tmp_BOOT_TYPE:-"systemd-boot"}
SWAP_SIZE=${tmp_SWAP_SIZE:-"2G"}
LOCALES=${tmp_LOCALES:-"fr_CH-latin1"}

## if using encryption we need to change the UUID
## for the root partition and the systemd-boot entry
if [[ $SHOULD_ENCRYPT_DISK =~ [Yy] ]]; then
    ROOT_PARTITION_UUID=$(cryptsetup luksUUID $PARTITION2)
else
    ROOT_PARTITION_UUID=$(blkid -sPARTUUID -ovalue ${PARTITION2})
fi
HOME_DIR="/home/${USERNAME}"


## show some nice messages to the user
## we all like colors don't we
function msg_ok()      { echo "$(tput setaf 2)[+] $1$(tput sgr0)";                     }
function msg_error()   { echo "$(tput setaf 1)[ERROR] $1$(tput sgr0)";                 }
function msg_warning() { echo "$(tput setaf 3)[WARNING] $1$(tput sgr0)";               }
function PRESS_ENTER() { read -p "$(tput setaf 3)Press ENTER to continue$(tput sgr0) ";}

## Need to set root password
## It should be changed after the installation
msg_warning "Setting password for use root to root"
msg_warning "Please change the root password after the installation"
echo -e "root\nroot" | passwd root
PRESS_ENTER


function is_virtual_machine
{
    if grep -Eiq "VMware|VirtualBox" /sys/class/dmi/id/sys_vendor \
        || sudo dmidecode|grep -Eiq "VMware|VirtualBox"
    then
        return 0
    else
        return 1
    fi
}


function create_swapfile
{
    ## equivalent to:
    ## dd if=/dev/zero of=/swapfile bs=1M count=1024
    if [[ ! -f /swapfile ]]; then
        msg_ok "Creating a ${SWAP_SIZE} swap file /swapfile"
        fallocate -l ${SWAP_SIZE} /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
    else
        msg_ok "Swap file already exists"
    fi
}


function configure_locales
{
    msg_ok "Applying locales ${LOCALES}"
    loadkeys ${LOCALES}
    msg_ok "Configured locales
    $(localectl)"
}


function write_persistent_locales
{
    msg_ok "Setting locales in /etc/locale.gen"
    cp /etc/locale.gen /etc/locale.gen.orig
    echo "en_US.UTF-8 UTF-8"    > /etc/locale.gen
    echo "en_US ISO-8859-1"     >> /etc/locale.gen
    echo "fr_CH.UTF-8 UTF-8"    >> /etc/locale.gen
    echo "fr_CH ISO-8859-1"     >> /etc/locale.gen
    echo "LANG=en_US.UTF-8"     > /etc/locale.conf
    echo "KEYMAP=${LOCALES}"    > /etc/vconsole.conf
    msg_ok "Generating locales with 'locale-gen'"
    locale-gen
}


function set_localtime
{
    msg_ok "Configure localtime for Europe/Zurich"
    ln -s -f /usr/share/zoneinfo/Europe/Zurich /etc/localtime
    hwclock --systohc --utc
}


function write_localhost_file
{
    msg_ok "Writing /etc/hosts file"
    cat <<-EOF > /etc/hosts
		# Static table lookup for hostnames.
		# See hosts(5) for details.
		127.0.0.1       localhost
		::1             localhost
		127.0.0.1       ${HOSTNAME}.localdomain ${HOSTNAME}
	EOF
}


function write_hostname_file
{
    msg_ok "Setting the hostname to ${HOSTNAME}"
    echo ${HOSTNAME} > /etc/hostname
}


function install_bootloader
{
    if echo "${BOOT_TYPE}"|grep -qEo "systemd-boot"; then
        msg_ok "Installing systemd-boot"
        bootctl --path=/boot install

        msg_ok "Adding systemd loader configuration to /boot/loader/loader.conf"
        echo "timeout 2" > /boot/loader/loader.conf
        echo "default arch-*" >> /boot/loader/loader.conf

        if [[ $SHOULD_ENCRYPT_DISK =~ [Yy] ]]; then
            SYSTEMD_BOOT_OPTIONS="options cryptdevice=UUID=${ROOT_PARTITION_UUID}:root root=${PARTITION_LUKS} quiet rw net.ifnames=0 transparent_hugepage=never"
        else
            SYSTEMD_BOOT_OPTIONS="options root=PARTUUID=${ROOT_PARTITION_UUID} quiet rw net.ifnames=0 transparent_hugepage=never"
        fi

        msg_ok "Adding first entry to loader: /boot/loader/entries/arch.conf"
        cat <<-EOF > /boot/loader/entries/arch.conf
			title Arch Linux
			linux /vmlinuz-linux
			initrd /intel-ucode.img
			initrd /initramfs-linux.img
			${SYSTEMD_BOOT_OPTIONS}
		EOF

        msg_ok "Adding first entry to loader: /boot/loader/entries/arch-lts.conf"
        cat <<-EOF > /boot/loader/entries/arch-lts.conf
			title Arch Linux LTS
			linux /vmlinuz-linux-lts
			initrd /intel-ucode.img
			initrd /initramfs-linux-lts.img
			${SYSTEMD_BOOT_OPTIONS}
		EOF
    else
        # bootctl remove &>/dev/null
        msg_ok "Installing GRUB ..."
        pacman -S --noconfirm grub efibootmgr
        grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB
        msg_ok "Changing /etc/default/grub configuration file"
        sed -i -e 's/GRUB_CMDLINE_LINUX="\(.\+\)"/GRUB_CMDLINE_LINUX="\1 cryptdevice='"${PARTITION2}"':root"/g' -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cryptdevice='"${PARTITION2}"':root"/g' /etc/default/grub
        echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
        msg_ok "Generating GRUB configuration file /boot/grub/grub.cfg"
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
}


function enable_pacman_multilib
{
    msg_ok "Enable multilib support in /etc/pacman.conf"
    cp /etc/pacman.conf /etc/pacman.conf.backup
    ## to replace new lines in new sed verions the [:a;N;] can be replaced with [sed -z]
    sed -i ':a;N;s|#\[multilib\]\n#Include|\[multilib\]\nInclude|' /etc/pacman.conf
    sed -i 's/#Color/Color/' /etc/pacman.conf
}


function rank_mirrors
{
    msg_ok "Ranking pacman mirrorlist"
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    (curl -s "https://www.archlinux.org/mirrorlist/?country=FR&country=GB&protocol=https&use_mirror_status=on" | \
        sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -) > /etc/pacman.d/mirrorlist
}


function refresh_pacman_database
{
    msg_ok "Refresh pacman package databases from the server"
    pacman -Syy
}


function install_packages
{
    if curl -q https://raw.githubusercontent.com/boogy/dotfiles/master/deploy/packages/archlinux --output packages.txt; then
        PACKAGES_FILE=./packages.txt
    else
        PACKAGES_FILE=../packages/archlinux
    fi

    if [[ -f ${PACKAGES_FILE} ]]; then
        while read line; do
            if [[ ! "${line}" =~ (^#|^$) ]]; then
                packages="${packages} ${line}"
            fi
        done < ${PACKAGES_FILE}
        msg_ok "Intalling packages"
        echo "pacman -S --noconfirm ${packages}" > install_packages.sh
        bash install_packages.sh
    else
        msg_error "No packages were provided for installation"
        read -p "$(tput setaf 3)[?] Continue without packages: [Y/n]:$(tput sgr0) " PKG_CONTINUE
        if [[ $PKG_CONTINUE =~ [nN] ]]; then
            exit 1
        else
            msg_warning "You may have errors in functions that require packages to be installed !!!"
            return 0
        fi
    fi
}


function create_user_account
{
    msg_ok "Creating username: ${USERNAME}"
    useradd -m -g users -G wheel,games,power,optical,storage,scanner,lp,audio,video,docker -s /bin/bash ${USERNAME}
    msg_warning "Setting password for ${USERNAME} to ${USERNAME}"
    msg_warning "Please change the password after the installation"
    echo -e "${USERNAME}\n${USERNAME}" | passwd ${USERNAME}
    PRESS_ENTER
}


function manage_services
{
    msg_ok "Enabeling some services"
    systemctl enable lightdm.service           &>/dev/null
    systemctl enable bluetooth.service         &>/dev/null
    systemctl enable docker.service            &>/dev/null
    systemctl enable NetworkManager.service    &>/dev/null

    ## this needs to be disabled to have sound
    ## pulseaudio will be started in i3 config
    msg_ok "Disable pulseaudio.socket for the user ${USERNAME}"
    sudo -u ${USERNAME} systemctl --user disable pulseaudio.socket
}


function configure_mkinitcpio_hooks
{
    msg_warning "Make sure to edit the /etc/mkinitcpio.conf file to look like this:"
    msg_warning "..."
    msg_warning "ORIGINAL ENTRY"
    msg_warning "HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)"
    msg_warning "..."
    msg_warning "NEW ENTRY"
    msg_warning "HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems fsck)"
    msg_warning "..."

    msg_ok "Making a backup of /etc/mkinitcpio.conf"
    cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.orig

    msg_ok "Adding hooks to /etc/mkinitcpio.conf"
    sed -i "s/^\(HOOKS=\)/#\1/" /etc/mkinitcpio.conf
    if [[ $SHOULD_ENCRYPT_DISK =~ [yY] ]]; then
        sed -i "/#HOOKS=(base/a HOOKS=(base udev autodetect modconf block keyboard keymap encrypt filesystems fsck)" /etc/mkinitcpio.conf
    else
        sed -i "/#HOOKS=(base/a HOOKS=(base systemd udev autodetect modconf block keyboard keymap filesystems fsck)" /etc/mkinitcpio.conf
    fi

    msg_ok "Generate kernel images with 'mkinitcpio -P'"
    mkinitcpio -P
}


function add_systemd_tty_rate_service
{
    msg_ok "Add systemd service for keyboard tty rate"
    cat <<-EOF > /etc/systemd/system/kbdrate.service
		[Unit]
		Description=Keyboard repeat rate in tty.

		[Service]
		Type=oneshot
		RemainAfterExit=yes
		StandardInput=tty
		StandardOutput=tty
		ExecStart=/usr/sbin/kbdrate -s -d 200 -r 50

		[Install]
		WantedBy=multi-user.target
	EOF
    msg_ok "Enable kbdrate.service"
    systemctl enable kbdrate.service
}


function configure_xorg_keaboard
{
    msg_ok "Configure keyboard in xorg"
    cat <<-EOF > /etc/X11/xorg.conf.d/00-keyboard.conf
		Section "InputClass"
		        Identifier "system-keyboard"
		        MatchIsKeyboard "on"
		        Option "XkbLayout" "ch"
		        Option "XkbModel" "pc105"
		        Option "XkbVariant" ",fr"
		        Option "XkbOptions" "lv3:ralt_switch"
		EndSection
	EOF
}


function add_libinput_xorg_config
{
    msg_ok "Writing libinput X11 configuration"
    cat <<-EOF > /etc/X11/xorg.conf.d/30-touchpad.conf
		Section "InputClass"
		        Identifier "MyTouchpad"
		        MatchIsTouchpad "on"
		        Driver "libinput"
		        Option "Tapping" "on"
		        Option "Natural Scrolling" "on"
		EndSection
	EOF
}

function add_xorg_graphics
{
    ## for vms do not use X11 intel driver
    if is_virtual_machine; then
        USE_INTEL_GRAPHICS_default="n"
    else
        USE_INTEL_GRAPHICS_default="y"
    fi

    read -p "$(tput setaf 2)[??] Do you use INTEL GRAPHICS ? [Y/n]:$(tput sgr0) " USE_INTEL_GRAPHICS_tmp
    USE_INTEL_GRAPHICS=${USE_INTEL_GRAPHICS_tmp:-$USE_INTEL_GRAPHICS_default}

    if [[ $USE_INTEL_GRAPHICS =~ [Y|y] ]]; then
        msg_ok "Writing X11 intel configuration"
        cat <<-EOF > /etc/X11/xorg.conf.d/20-intel.conf
			Section "Device"
			        Identifier "Intel Graphics"
			        Driver "intel"
			EndSection
		EOF
    fi
}


function add_libinput_gestures_config
{
    msg_ok "Adding lininput configuration file in users ${HOME_DIR}"
    mkdir -p ${HOME_DIR}/.config
    cat <<-EOF > ${HOME_DIR}/.config/libinput-gestures.conf
		# ~/.config/libinput-gestures.conf

		# Go back/forward in chrome
		gesture: swipe right 3 xdotool key Alt+Left
		gesture: swipe left 3 xdotool key Alt+Right

		# Zoom in / Zoom out
		gesture: pinch out xdotool key Ctrl+plus
		gesture: pinch in xdotool key Ctrl+minus

		# Switch between desktops
		gesture: swipe left 4 xdotool set_desktop --relative 1
		gesture: swipe right 4 xdotool set_desktop --relative -- -1
	EOF
}


function configure_lightdm
{
    ## https://wiki.archlinux.org/index.php/LightDM
    msg_ok "Configure lightdm"
    cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.orig
    cat <<-EOF > /etc/lightdm/lightdm.conf
		[LightDM]
		run-directory=/run/lightdm

		[Seat:*]
		greeter-session=lightdm-gtk-greeter
		session-wrapper=/etc/lightdm/Xsession

		[XDMCPServer]

		[VNCServer]
	EOF

    ## https://wiki.archlinux.org/index.php/LightDM#GTK.2B_greeter
    msg_ok "Configure lightdm-gtk-greeter"
    msg_ok "Setting default lightdm icon to: /var/lib/AccountsService/icons/icon.png"
    msg_ok "Setting default lightdm background to: /usr/share/pixmaps/lightdm_background.jpg"
    cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.orig
    cat <<-EOF > /etc/lightdm/lightdm-gtk-greeter.conf
		[greeter]
		theme-name = Arc
		icon-theme-name = Arc
		background = /usr/share/pixmaps/lightdm_background.jpg
		default-user-image = /var/lib/AccountsService/icons/icon.png
		screensaver-timeout = 0
		user-background = false

		[monitor: eDP1]
		background = /usr/share/pixmaps/lightdm_background.jpg

		[monitor: DP2-1]
		background = /usr/share/pixmaps/lightdm_background.jpg

		[monitor: DP1-2]
		background = /usr/share/pixmaps/lightdm_background.jpg
	EOF

}


function add_sudoers_configuration
{
    msg_ok "Add user ${USERNAME} to sudoers"
    cp /etc/sudoers /etc/sudoers.backup
    cat <<-EOF > /etc/sudoers
		##
		## Defaults
		##
		Defaults !tty_tickets
		Defaults !mail_badpass
		Defaults editor=/usr/sbin/vim, !env_editor
		Defaults passwd_timeout=620
		Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
		##
		## User privilege specification
		##
		root    ALL=(ALL) ALL
		${USERNAME}     ALL=(ALL:ALL) ALL, NOPASSWD: /usr/sbin/pacman -Syu, \
		                                     /usr/sbin/pacman -Syy, \
		                                     /usr/sbin/systemctl start *, \
		                                     /usr/sbin/systemctl status *, \
		                                     /usr/sbin/systemctl restart *, \
		                                     /usr/sbin/systemctl stop *, \
		                                     /usr/sbin/systemctl list-unit-files *, \
		                                     /usr/sbin/systemctl list-units *, \
		                                     /usr/sbin/systemctl is-enabled *, \
		                                     /usr/sbin/systemctl shutdown, \
		                                     /usr/sbin/systemctl suspend, \
		                                     /usr/sbin/systemctl hibernate, \
		                                     /usr/sbin/reboot, \
		                                     /usr/sbin/poweroff, \
		                                     /usr/sbin/lsof, \
		                                     /usr/sbin/dmidecode
		## Read drop-in files from /etc/sudoers.d
		## (the '#' here does not indicate a comment)
		#includedir /etc/sudoers.d
	EOF
}


function add_sysctl_params
{
    local old_IFS=$IFS
    local IFS=$'\n'
    SYSCTL_PARAMS=(
        'vm.swappiness = 10'
        'vm.vfs_cache_pressure = 50'
    )
    msg_ok "Add sysctl performance options"
    for OPT in ${SYSCTL_PARAMS[@]}; do
        value_name=$(echo ${OPT}|sed -e 's/[ \t=]\+.*//g')
        if grep -q "${value_name}" /etc/sysctl.d/99-sysctl.conf ; then
            msg_warning "${value_name} is already set"
        else
            echo ${O} >> /etc/sysctl.d/99-sysctl.conf
        fi
    done
    IFS=$old_IFS
}


function clone_dot_config
{
    local DOT_CONFIGS=${1:-"https://github.com/${USERNAME}/dotfiles"}
    msg_ok "Setting up the ${USERNAME}'s dotfiles environment"
    sudo -u ${USERNAME} git clone ${DOT_CONFIGS} /home/${USERNAME}/${DOT_CONFIGS##*/}
}


function install_powerline_fonts
{
    msg_ok "Installing powerline fonts"
    cd /home/${USERNAME}
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts \
        && ./install.sh \
        && cd .. \
        && rm -rf fonts
}


function install_aur_wrapper
{
    sudo -u ${USERNAME} bash -c "git clone https://aur.archlinux.org/yay.git ${HOME}/yay"
    sudo -u ${USERNAME} bash -c "cd ${HOME}/yay; makepk -s --noconfirm" \
        && pacman -U --noconfirm /home/${USERNAME}/yay/yay-*-x86_64.pkg.tar.xz
}


function install_aur_packages
{
    if command -v yay &>/dev/null; then
        ## Install AUR packages
        yay --noconfirm -S systemd-boot-pacman-hook
        yay --noconfirm -S chromium-widevine ## chromium needs this to play protected content
        yay --noconfirm -S dropbox && systemctl --user disable dropbox.service
        yay --noconfirm -S polybar
        yay --noconfirm -S libinput-gestures
        yay --noconfirm -S vmware-workstation
        yay --noconfirm -S visual-studio-code-bin
        yay --noconfirm -S jre8-openjdk jdk8-openjdk
        yay --noconfirm -S jre10-openjdk jdk10-openjdk
        yay --noconfirm -S gksu
        yay --noconfirm -S openfortivpn
        yay --noconfirm -S nessus
        yay --noconfirm -S otf-font-awesome-4 otf-font-awesome-5-free ttf-ms-fonts
        yay --noconfirm -S xcursor-oxygen
        yay --noconfirm -S xcursor-breeze-serie-obsidian
        yay --noconfirm -S j4-dmenu-desktop
    else
        msg_warning "Can't install AUR packages: there is no AUR tool installed"
        msg_warning "Check out this documentation: https://wiki.archlinux.org/index.php/AUR_helpers"
    fi
}


## swap files are better to use then partitions
create_swapfile

## configure system locales (default fr_CH-latin1)
configure_locales

## set the localetime (default Europe/Zurich)
set_localtime

## write the /etc/hosts file
write_localhost_file

## add hostname to the /etc/hostname file
write_hostname_file

## save locales configuration to proper files
write_persistent_locales

## install a bootloader (default: systemd-boot)
install_bootloader

## enable pacman multilib support
enable_pacman_multilib

## rank the fastest 5 mirrors
rank_mirrors

## do a refresh of the pacman package database
refresh_pacman_database

## install desired packages
install_packages

## create a user account on the system
create_user_account

## manage services that should be on or off
manage_services

## configure mkinitcpio to add the proper hooks
configure_mkinitcpio_hooks

## change the speed of the keyboard in the console tty
add_systemd_tty_rate_service

## configure xorg with the proper keyboard configuration
configure_xorg_keaboard

## use libinput by default
add_libinput_xorg_config
add_xorg_graphics

## write libinput gestures configuration file
add_libinput_gestures_config

## display manager for the login (lightdm)
configure_lightdm

## add a pre-filled sudoers file
# add_sudoers_configuration

## sysctl configuration options
add_sysctl_params

## clone personal dotfiles from github
clone_dot_config

## installe powerline fonts
install_powerline_fonts

## install AUR wrappers
install_aur_wrapper

## some AUR packages everyone should install :)
install_aur_packages

msg_ok "Make sure the file is owned by the user ${USERNAME}"
chown -R ${USERNAME}: ${HOME_DIR}

msg_ok "Exiting installation in chroot environment ..."
msg_ok "Removing install script $(basename $0)"

test -f /sysprep_archlinux_chroot.sh \
    && rm -f /sysprep_archlinux_chroot.sh


##
## Misc options
##

## Further performance improvements for /etc/fstab
# -> noatime,commit=60
#

## Add these lines in each VM_name.vmx file to ensure direct RAM access
# MemTrimRate = "0"
# sched.mem.pshare.enable = "FALSE"
# prefvmx.useRecommendedLockedMemSize = "TRUE"
# mainmem.backing = "swap"

## Vmware modules to load
# msg_ok "Setting vmware kernel modules to load automaticaly"
# cat <<EOF > /etc/modules-load.d/vmware.conf
# vmnet
# vmmon
# vmw_vmci
# EOF

# cat /etc/systemd/system/multi-user.target.wants/vmware-networks.service
# [Unit]
# Description=VMware Networks
# Wants=vmware-networks-configuration.service
# After=vmware-networks-configuration.service
#
# [Service]
# Type=forking
# Restart=always
# ExecStartPre=-/sbin/modprobe vmnet
# ExecStart=/usr/bin/vmware-networks --start
# ExecStop=/usr/bin/vmware-networks --stop
#
# [Install]
# WantedBy=multi-user.target

## cat /etc/systemd/system/multi-user.target.wants/vmware-usbarbitrator.service
# [Unit]
# Description=VMware USB Arbitrator
#
# [Service]
# ExecStart=/usr/lib/vmware/bin/vmware-usbarbitrator -f
# ExecStop=/usr/lib/vmware/bin/vmware-usbarbitrator -k
#
# [Install]
# WantedBy=multi-user.target


# msg_ok "Loading bbswitch kernel module"
# cat <<EOF > /etc/modules-load.d/bbswitch.conf
# bbswitch
# EOF
