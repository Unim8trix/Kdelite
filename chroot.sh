#!/usr/bin/sh

init() {
    # Vars
    USERNAME='me'
    HOSTNAME='hadal'

    # Colors
    NORMAL=$(tput sgr0)
    WHITE=$(tput setaf 7)
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    BRIGHT=$(tput bold)
    UNDERLINE=$(tput smul)
}

confirm() {
    echo -en "[${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 0
    fi
}

print_header() {
    clear
    echo -E "$BLUE
     ____ ___      .__           ______  __         .__
    |    |   \____ |__| _____   /  __  \/  |________|__|__  ___
    |    |   /    \|  |/     \  >      <   __\_  __ \  \  \/  /
    |    |  /   |  \  |  Y Y  \/   --   \  |  |  | \/  |>    <
    |______/|___|__/__|__|_|__/\________/__|  |__|  |__/__/\__\

                $WHITE https://github.com/Unim8trix $NORMAL
"
}

install() {
    clear
    echo -e "${YELLOW}Phase 2: Configure system and install software${NORMAL}\n"
    echo -e "${YELLOW}Ready?${NORMAL}\n"
    confirm
    cd

    echo -e "${YELLOW}Set hostname${NORMAL}\n"
    echo "${HOSTNAME}" > /etc/hostname

    echo -e "${YELLOW}Set locales${NORMAL}\n"
    echo "LANG=de_DE.UTF-8" > /etc/locale.conf
    echo "LANGUAGE=de_DE" >> /etc/locale.conf

    echo -e "${YELLOW}Set keymap and font in vcsonole${NORMAL}\n"
    echo "KEYMAP=de-latin1-nodeadkeys" > /etc/vconsole.conf
    echo "FONT=sun12x22" >> /etc/vconsole.conf

    echo -e "${YELLOW}Set symlink to timezone${NORMAL}\n"
    ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

    echo -e "${YELLOW}Set localhost informations in hosts${NORMAL}\n"
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1 localhost" >> /etc/hosts
    echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

    echo -e "${YELLOW}Set UTF-8 locales${NORMAL}\n"
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
    echo "de_DE ISO-8859-1" >> /etc/locale.gen
    echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Disable powersaving for WLAN card${NORMAL}\n"
    echo "[connection]" > /etc/NetworkManager/conf.d/wifi-powersave-off.conf
    echo "wifi.powersave=2" >> /etc/NetworkManager/conf.d/wifi-powersave-off.conf
    echo "options iwlwifi power_save=0" > /etc/modprobe.d/iwlwifi.conf
    echo "options iwlwifi uapsd_disable=0" >> /etc/modprobe.d/iwlwifi.conf
    echo "options iwlmvm power_scheme=1" >> /etc/modprobe.d/iwlwifi.conf
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Creating new local user${NORMAL}\n"
    useradd -m -G users,wheel,lp,power,audio -s /bin/zsh ${USERNAME}
    echo "%wheel ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
    echo -e "${YELLOW}Set password for your new user${NORMAL}\n"
    passwd ${USERNAME}
    echo "export EDITOR='nvim'" > /home/${USERNAME}/.zshrc
    echo "autoload -Uz compinit promptinit" >> /home/${USERNAME}/.zshrc
    echo "compinit" >> /home/${USERNAME}/.zshrc
    echo "promptinit" >> /home/${USERNAME}/.zshrc
    echo "prompt suse" >> /home/${USERNAME}/.zshrc
    echo "alias ll='ls -lah'" >> /home/${USERNAME}/.zshrc
    echo "alias cls='clear'" >> /home/${USERNAME}/.zshrc
    echo "alias vim='nvim'" >> /home/${USERNAME}/.zshrc
    chown ${USERNAME}:users /home/${USERNAME}/.zshrc
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Update pacman mirrorlist${NORMAL}\n"
    reflector --country Germany --latest 10 --sort score --protocol https --save /etc/pacman.d/mirrorlist
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Configure initial ramdisk${NORMAL}\n"
    sed -i 's/MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
    sed -i 's/HOOKS=.*/HOOKS=(base systemd keyboard autodetect microcode modconf kms block sd-vconsole sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf
    mkinitcpio -P
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Install systemd bootloader${NORMAL}\n"
    bootctl --path=/boot install
    sleep 1
    echo -e "${YELLOW}Configure bootloader entries${NORMAL}\n"
    sleep 0.5
    echo "default arch.conf" > /boot/loader/loader.conf
    echo "timeout 2" >> /boot/loader/loader.conf
    echo "editor 0" >> /boot/loader/loader.conf
    echo "title Arch Linux" > /boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux-zen" >> /boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux-zen.img" >> /boot/loader/entries/arch.conf
    echo "options rd.luks.name=$(blkid -s UUID -o value /dev/nvme0n1p3)=cryptsys rd.luks.options=password-echo=no root=/dev/mapper/cryptsys rw" >> /boot/loader/entries/arch.conf
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1


    echo -e "${YELLOW}Add crypted swap partition${NORMAL}\n"
    sleep 1
    echo "cryptswap  /dev/nvme0n1p2  /dev/urandom  swap,cipher=aes-xts-plain64,size=256" >> /etc/crypttab
    echo "/dev/mapper/cryptswap  none  swap  defaults  0 0" >> /etc/fstab
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Enable NetworkManager and timesync services${NORMAL}\n"
    systemctl enable NetworkManager
    systemctl enable systemd-timesyncd
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Install YAY package manager from AUR${NORMAL}\n"
    sed -i 's/debug/!debug/' /etc/makepkg.conf
    su ${USERNAME} -c "git clone https://aur.archlinux.org/yay.git /home/${USERNAME}/yay"
    su ${USERNAME} -c "makepkg -D /home/${USERNAME}/yay -is --noconfirm"
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Install Window manager and tools${NORMAL}\n"
    sleep 2
    su ${USERNAME} -c "yay --noconfirm -Sy vulkan-radeon mesa firefox-developer-edition-i18n-de \
      plasma-meta breeze-plymouth plymouth-theme-arch-charge plymouth-kcm \
      nordzy-cursors papirus-icon-theme papirus-folders-nordic \
      bluez-utils modemmanager usb_modeswitch btop \
      noto-fonts noto-fonts-emoji ghostty zed fzf jq yq \
      pipewire-alsa pipewire-pulse pipewire-jack sof-firmware alsa-firmware \
      starship fastfetch"
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 5

    echo -e "${YELLOW}Enable SDDM${NORMAL}\n"
    systemctl enable sddm
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Enable Plymouth Arch-Charge theme${NORMAL}\n"
    plymouth-set-default-theme -R arch-charge
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Configure ramdisk for plymouth${NORMAL}\n"
    sed -i 's/HOOKS=.*/HOOKS=(base systemd plymouth keyboard autodetect microcode modconf kms block sd-vconsole sd-encrypt filesystems fsck)/' /etc/mkinitcpio.conf
    mkinitcpio -P
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Modify systemd boot entry for plymouth${NORMAL}\n"
    sudo sed -i '/^options/ s/$/ quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0/' /boot/loader/entries/arch.conf
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1

    echo -e "${YELLOW}Create user directories${NORMAL}\n"
    su ${USERNAME} -c "mkdir -p /home/${USERNAME}/{.cache/nano/backups,.local/share/fonts,Bilder/Wallpapers,Bilder/Screenshots}"
    echo -e "${GREEN}Done${NORMAL}\n"
    sleep 1
}


main() {
    init
    print_header

    install
}

main && exit 0
