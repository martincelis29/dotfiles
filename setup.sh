#!/bin/bash

# Yes or No
function __read_yn {
    echo -en "$1"
    read yn
    yn=$(echo "$yn" | tr A-Z a-z)

    if [[ $yn =~ [yY] ]]; then
        return 0
    elif [[ $yn =~ [nN] ]]; then
        return -1
    elif [[ -z $yn ]]; then
        return $2
    fi

    return -1
}

# Packages
echo -e "\e[1;35mUpdating the system\e[0m"
sleep 1
sudo pacman -Syyu --noconfirm

echo -e "\e[1;35mInstalling pacman packages\e[0m"
# bluez bluez-utils blueman brightnessctl  hyprland
sleep 1
sudo pacman -S --needed --noconfirm \
    base base-devel git zsh acpi acpid wget kitty linux linux-firmware linux-headers openssh os-prober zip unzip intel-ucode xf86-video-intel vulkan-intel \
    networkmanager nm-connection-editor network-manager-applet reflector avahi \
    pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber pamixer alsa-utils sof-firmware \
    ntfs-3g rsync mtools dosfstools xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils efibootmgr \
    python python-pybluez python-dotenv python-pip python-pywal python-gobject python-requests dbus-python \
    qt5ct qt5-imageformats qt5-graphicaleffects qt5-svg gtk3 gtk4 gtk-layer-shell libpeas libdbusmenu-gtk3 \
    dunst xdg-desktop-portal xdg-desktop-portal-gtk \
    playerctl jq grim slurp swappy pacman-contrib ripgrep socat \
    papirus-icon-theme capitaine-cursors nautilus \
    neovim wl-clipboard polkit-gnome gammastep sushi eog zenity

# Install yay
if __read_yn "\e[1;33mInstall Yay? \e[0m[Y/n]"; then
    if [[ -x $(command -v yay) ]]; then
        echo -e "\e[1;35mYay it's already installed\e[0m"
    else
        echo -e "\e[1;35mInstalling Yay...\e[0m"
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        echo -e "\e[1;32mYay installed\e[0m"
    fi
fi

echo -e "\e[1;35mInstalling yay packages\e[0m"
sleep 1
yay -S --needed --noconfirm \
    papirus-folders-git

# Install Hyprland
if __read_yn "\e[1;33mInstall Hyprland? \e[0m[Y/n]"; then
    if [[ -x $(command -v hyprctl) ]]; then
        echo -e "\e[1;35mHyprland it's already installed\e[0m"
    else
        sudo pacman -S --needed --noconfirm \
            xdg-desktop-portal-hyprland wayland lib32-wayland qt5-wayland qt6-wayland \
            swaybg waybar swayidle wofi

        yay -S --needed --noconfirm \
            swaylock-effects-git hyprpicker-git

        echo -e "\e[1;35mInstalling Hyprland...\e[0m"
        git clone --recursive https://github.com/hyprwm/Hyprland
        cd Hyprland
        sudo make install
        cd ..
        echo -e "\e[1;32mHyprland installed\e[0m"
    fi
fi

# Opcional Packages
if __read_yn "\e[1;33mInstall optional packages? \e[0m[Y/n]"; then
    sudo pacman -S --needed --noconfirm \
        firefox discord steam \
        mpv spotify-launcher font-manager gnome-control-center \
        pavucontrol neofetch bat btop lsd

    yay -S --needed --noconfirm \
        cava visual-studio-code-bin
fi

# UFW
if __read_yn "\e[1;33mInstall UFW? \e[0m[Y/n]"; then
    if [[ -x $(command -v ufw) ]]; then
        echo -e "\e[1;35mUfw it's already installed\e[0m"
    else
        sudo pacman -S --needed --noconfirm \
            ufw

        sudo ufw enable
        sudo systemctl enable ufw.service
        sudo systemctl start ufw.service

        echo -e "\e[1;32mUFW installed\e[0m"
    fi
fi

# Flatpak
if __read_yn "\e[1;33mInstall flatpak? \e[0m[Y/n] "; then
    sudo pacman -S --needed --noconfirm \
        flatpak gnome-software

    echo -e "\e[1;32mFlatpak installed\e[0m"
    echo -e "\e[1;35mReboot required\e[0m"
fi

# Oh My Zsh
if __read_yn "\e[1;33mInstall Oh My Zsh? \e[0m[Y/n] "; then
    echo -e "\e[1;35mInstalling Oh My Zsh...\e[0m"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
    echo -e "\e[1;32mOh My Zsh installed\e[0m"
fi

# Config Files
if __read_yn "\e[1;33mWould you like to copy config files? \e[0m[Y/n] "; then
    echo -e "\e[1;35mCopying config files...\e[0m"
    cp -R .config/* ~/.config/
    cp -R .bashrc ~/
    cp -R .zshrc ~/
    cp -R .fonts/* /usr/share/fonts/
    cp -R .themes/* ~/.themes/
    chmod +x usr/bin/checkvolume
    cp -R usr/bin/checkvolume /usr/bin/
    chmod +x usr/bin/volume
    cp -R usr/bin/volume /usr/bin/
    cp -R Pictures/* ~/Pictures/
    papirus-folders -C violet Papirus-Dark
    echo -e "\e[1;32mConfig files copied\e[0m"
fi

# Starship
if __read_yn "\e[1;33mInstall Starship? \e[0m[Y/n] "; then
    sudo pacman -S --needed --noconfirm \
        starship
    echo -e "\e[1;35mCopying starship file..."
    cp -R .config/starship.toml ~/.config/
    echo -e "\e[1;32mStarship installed\e[0m"
fi

# GDM
if __read_yn "\e[1;33mInstall GDM(Display manager)? \e[0m[Y/n] "; then
    sudo pacman -S --needed --noconfirm \
        gdm

    sudo systemctl enable gdm.service

    echo -e "\e[1;32mGDM installed\e[0m"
fi

# GDM WhiteSur Theme
if __read_yn "\e[1;33mInstall GDM WhiteSur Theme? \e[0m[Y/n] "; then
    echo -e "\e[1;35mInstalling GDM WhiteSur Theme...\e[0m"
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
    cd WhiteSur-gtk-theme
    sudo ./tweaks.sh -g -b $HOME/Pictures/Space.jpg -t purple #Change Wallpaper
    cd ..
    echo -e "\e[1;32mGDM WhiteSur Theme installed\e[0m"
fi

if __read_yn "\e[1;33mDo you want to reboot? \e[0m[Y/n] "; then
    systemctl reboot
fi
