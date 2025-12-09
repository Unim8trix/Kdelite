<h1 align="center">
   <img src="./.github/assets/arch_logo.png  " width="200px" />
   <br>
      Arch Linux on HP Elitebook 845 G10 in KDE Plasma
   <br>
      <img src="./.github/assets/nord_palet.png" width="600px" /> <br>

   <div align="center">
      <p></p>
      <div align="center">
         <a href="https://github.com/Unim8trix/Kdelite/stargazers">
            <img src="https://img.shields.io/github/stars/Unim8trix/Kdelite?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F">
         </a>
         <a href="https://github.com/Unim8trix/Kdelite/">
            <img src="https://img.shields.io/github/repo-size/Unim8trix/Kdelite?color=B16286&labelColor=282828&style=for-the-badge&logo=github&logoColor=B16286">
         </a>
         <a = href="https://archlinux.org">
            <img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&labelColor=282828&logo=arch-linux&logoColor=458588&color=458588">
         </a>
         <a href="https://github.com/Unim8trix/Kdelite/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=282828&colorB=98971A&logo=unlicense&logoColor=98971A&"/>
         </a>
      </div>
      <br>
   </div>
</h1>


### 🖼️ Gallery

<p align="center">
   <img src="./.github/assets/kdelite_1.png" style="margin-bottom: 10px;"/> <br>
   <img src="./.github/assets/kdelite_2.png" style="margin-bottom: 10px;"/> <br>
   Screenshots last updated <b>12.2025</b>
</p>

# 🗃️ Overview

This are my scripts on setting up a HP Elitebook 845 G10 with Arch Linux using Hyprland as window manager.

Iam using full disk encryption , main usage is Cloud Development, Virtualization and some gaming.

Localisations are for german, so adjust for your own needs.

## 📚 Layout

-   [install.sh](install.sh) 📜 Shell script for setting up the complete stuff
-   [config](config) ⚙️ configuration files
-   [fonts](fonts) ⚙️ fonts
-   [wallpapers](wallpapers/) 🌄 wallpapers

## 📦 List of installed Packages

| Arch packages                          | Description                                                                                   |
| :--------------------------------------| :---------------------------------------------------------------------------------------------|
| **vulkan-radeon mesa**                 | OpenGL and Vulkan drivers for amd gpu |
| **plasma-meta**                        | KDE Plasma Meta Package |
| **breeze-gtk kde-gtk-config kde-system-meta kde-utilities-meta dolphin okular** | KDE Apps |
| **firefox-developer-edition-i18n-de**  | My default browser |
| **plymouth plymouth-theme-arch-charge**| Plymouth boot splash screen |
| **ghostty**                            | My default terminal |
| **zed**                                | My default editor |
| **starship**                           | Customize terminal shell |
| **papirus-icon-theme nordzy-cursor**   | Some theming stuff |
| **noto-fonts noto-fonts-emoji**        | System fonts |
| **nano fastfetch fzf jq yq**           | Some CLI tools |
| **pipewire sof-firmware alsa-firmware** | Audio server and firmware |

# 🚀 Installation

> [!CAUTION]
> Applying custom configurations, especially those related to your operating system, can have unexpected consequences and may interfere with your system's normal behavior. While I have tested these configurations on my own setup, there is no guarantee that they will work flawlessly for you.

> **I am not responsible for any issues that may arise from using this configuration.**

> [!NOTE]
> This configuration is build for the HP Elitebook 845 G10.
>If you want to use it with your hardware you to review the configuration contents and make necessary modifications to customize it to your needs before attempting the installation!

## Boot arch linux live image

Get the latest live image from [Arch Linux Website](https://archlinux.org/download/) and make a bootable USB stick. Boot the
elitebook with the USB stick.

## Clone this repo and start Installation

Set your keyboard, activate network and clone this repo.

```bash
loadkeys de-latin1-nodeadkeys
iwctl
# station wlan0 connect "YOUR_WLAN_SSID"
timedatectl set-timezone Europe/Berlin
timedatectl set-ntp true
pacman -Sy git
git clone https://github.com/Unim8trix/Kdelite
cd Kdelite
./install.sh
```

# 📝 Manual Config

## Secure Boot

I had issues with secure boot, so i disabled it in BIOS. But some times it works..

First, go into BIOS Settings: Secure Boot, enable **Clear Keys**, save and reboot.

Install sbctl

```bash
yay -Sy sbctl
```

Create keys (i dont include microsoft ca)

```bash
sudo sbctl create-keys
```

Check if secure boot is in setup mode, if not reboot and enable "Clear keys..." in BIOS

```bash
sudo sbctl status
```

Enroll keys and sign

```bash
sudo sbctl enroll-keys

sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi

# enable automatic signing using pacman hook
sudo systemctl enable --now systemd-boot-update.service

# check
sudo sbctl verify
```

Now reboot,  boot with secure bios would be automaticly enabled (check with `sudo sbctl status`)

## Gaming

Enable 32-Bit Lib

Comment out `[multilib]` section in `/etc/pacman.conf`

```bash
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Install Vulkan Driver and Libs

```bash
yay -Sy lib32-mesa lib32-vulkan-radeon lib32-vulkan-icd-loader lib32-systemd ttf-liberation
```

Reboot your book and start installing the steam client


```bash
yay -Sy steam
```


<div align="right">
  <a href="#readme">Back to the Top</a>
</div>
