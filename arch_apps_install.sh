#!/bin/bash

##         ##
##  BASIC  ##
##         ##
select_basics() {
    exec 3>&1
    BASICS=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which apps you would like to install." 60 40 5 \
        Nano "" on \
        Vim "" off \
        gedit "" on \
        htop "" on \
        feh "" on \
        Okular "" on \
        VLC "" on \
        Alacritty "" on \
        Nitrogen "" on \
        2>&1 1>&3))
    exec 3>&-
    clear
}

install_basics() {
    for item in "${BASICS[@]}"
    do
        case $item in 
            "Nano")
                pacman -S nano --noconfirm
                ;;

            "Vim")
                pacman -S vim --noconfirm
                ;;

            "gedit")
                pacman -S gedit --noconfirm
                ;;

            "htop")
                pacman -S htop --noconfirm
                ;;

            "feh")
                pacman -S feh --noconfirm
                ;;

            "Okular")
                pacman -S okular --noconfirm
                ;;

            "VLC")
                pacman -S vlc --noconfirm
                ;;

            "Alacritty")
                pacman -S alacritty --noconfirm
                ;;

            "Nitrogen")
                pacman -S nitrogen --noconfirm
                ;;
        esac
    done 
}

##        ##
##  IDEs  ##
##        ##
select_ides() {
    exec 3>&1
    IDES=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which IDEs you would like to install." 60 40 5 \
        Code "" on \
        Emacs "" off \
        IntelliJ "" on \
        PyCharm "" off \
        "Android_Studio" "(AUR)" off \
        Arduino "" off \
        2>&1 1>&3))
    exec 3>&-
    clear
}

install_ides() {
    for item in "${IDES[@]}"
    do
        case $item in 
            "Code")
                pacman -S code --noconfirm
                ;;

            "Emacs")
                pacman -S emacs --noconfirm
                ;;

            "IntelliJ")
                pacman -S intellij-idea-community-edition --noconfirm
                ;;

            "PyCharm")
                pacman -S pycharm-community-edition --noconfirm
                ;;

            "Android_Studio")
                #yay -S android-studio --noconfirm
                echo -e "AUR support not yet implemented."
                ;;

            "Arduino")
                pacman -S arduino arduino-avr-core --noconfirm
                ;;
        esac
    done 
}

##            ##
##  BROWSERS  ##
##            ##
select_browsers () {
    exec 3>&1
    BROWSERS=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which browsers you would like to install." 60 40 5 \
        Firefox "" on \
        Konqueror "" on \
        Brave "(AUR)" off \
        Chrome "(AUR)" off \
        2>&1 1>&3))
    exec 3>&-
    clear
}

install_browsers () {
    for item in "${BROWSERS[@]}"
    do
        case $item in 
            # Firefox
            "Firefox")
                pacman -S firefox --noconfirm
            ;;

            "Konqueror")
                pacman -S konqueror --noconfirm
            ;;

            "Brave")
                # yay -S brave-bin --noconfirm
                echo -e "AUR support not yet implemented."
            ;;

            "Chrome")
                # yay -S google-chrome --noconfirm
                echo -e "AUR support not yet implemented."
            ;;
        esac
    done 
}


##            ##
##  DESKTOPS  ##
##            ##
select_desktops () {
    exec 3>&1
    DESKTOPS=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which desktop environments you would like to install." 60 40 5 \
        "Plasma_Minimal" "" on \
        "Plasma_Full" "" off \
        2>&1 1>&3))
    exec 3>&-
    clear
}

install_desktops() {
    for item in "${DESKTOPS[@]}"
    do
        case $item in 
            # Minimal KDE Plasma
            "Plasma_Minimal")
                echo -e "Installing KDE Plasma desktop..."
                pacman -S plasma-desktop --noconfirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install plasma-desktop. Aborting install..."
                    exit $?
                fi

                # Install basic plasma packages
                echo -e "Installing basic applications for KDE Plasma"
                pacman -S packagekit-qt5 plasma-systemmonitor plasma-nm plasma-pa dolphin konsole kdeplasma-addons kde-gtk-config discover kate --noconfirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install basic Plasma apps. Aborting install..."
                    exit $?
                fi
            ;;

            # Full KDE Plasma
            "Plasma_Full")
                echo -e "Installing Plasma via plasma-meta..."
                pacman -S plasma-meta --noconfirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install plasma-meta. Aborting install..."
                    exit $?
                fi

                # Install plasma applications
                echo -e "Installing KDE applications..."
                pacman -S kde-applications --noconfirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install KDE applications. Aborting install..."
                    exit $?
                fi
            ;;
        esac
    done
}


# Welcome
echo -e "\n\n\n\nWelcome to the Taylor Giles Arch Applications install script!"
echo -e "IMPORTANT: This script assumes that you have already completed basic installation of Arch Linux."
echo -e "If you have not yet installed Arch, please exit and install Arch now."
echo -e "\n"

read -p "Press [ENTER] to continue..."
echo -e "\n"

# Update system
echo -e "Updating system..."
pacman -Syu --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to update system. Aborting install..."
	exit $?
fi

# Install video driver
echo -e "\nPreparing to install graphics driver."
echo -e "Please select the option which best matches your graphics hardware, or skip this step:"
select DRIVER_TYPE in AMD Intel NVIDIA VirtualBox Skip
do
    case $DRIVER_TYPE in 
        "AMD")
            pacman -S xf86-video-amdgpu --noconfirm
            break
        ;;

        "Intel")
            pacman -S xf86-video-intel --noconfirm
            break
        ;;

        "NVIDIA")
            pacman -S xf86-video-nouveau --noconfirm
            break
        ;;

        "VirtualBox")
            pacman -S virtualbox-guest-utils xf86-video-vmware --noconfirm
            systemctl enable vboxservice
        break
        ;;

        "Skip")
            echo -e "Skipping graphics driver installation."
        break
        ;;

        *)
            echo -e "Please make a valid selection."
        ;;
    esac
done
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install graphics drivers. Aborting install..."
	exit $?
fi

# Install dialog
echo -e "Installing dialog..."
pacman -S dialog --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install dialog. Aborting install..."
	exit $?
fi

# Make selections
select_basics
select_desktops
select_browsers
select_ides

# Install Xorg
echo -e "Installing xorg..."
pacman -S xorg xorg-xinit --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install xorg. Aborting install..."
	exit $?
fi

# Install mesa
echo -e "Installing mesa..."
pacman -S mesa --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install mesa. Aborting install..."
	exit $?
fi

# Install SDDM
echo -e "Installing SDDM..."
pacman -S sddm --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install SDDM. Aborting install..."
	exit $?
fi

# Enable SDDM
echo -e "Enabling SDDM..."
systemctl enable sddm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to enable SDDM. Aborting install..."
	exit $?
fi

# Install git
echo -e "Installing git..."
pacman -S git --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install git. Aborting install..."
	exit $?
fi

# # Install yay
# echo -e "Installing yay..."
# cd /opt

# git clone https://aur.archlinux.org/yay.git
# if [ $? -ne 0 ]
# then
# 	echo "ERROR: Failed to install yay. Aborting install..."
# 	exit $?
# fi

# chown -R "$USER":users yay
# if [ $? -ne 0 ]
# then
# 	echo "ERROR: Failed to change ownership for yay. Aborting install..."
# 	exit $?
# fi

# cd - # Make sure the previous directory is not lost

# # Give the <nobody> user permissions in the /opt/yay directory
# setfacl -R -m u:nobody:rwx /opt/yay

# cd /opt/yay
# sudo -u nobody makepkg -si --noconfirm # Build package as <nobody> user
# if [ $? -ne 0 ]
# then
# 	echo "ERROR: Failed to build yay. Aborting install..."
# 	exit $?
# fi
# cd - # Go back to previous directory

# Do installations
install_basics
install_desktops
install_browsers
install_ides

