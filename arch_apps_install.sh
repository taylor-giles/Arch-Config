#!/bin/bash

##            ##
##  BROWSERS  ##
##            ##
select_browsers () {
    exec 3>&1
    BROWSERS=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which browsers you would like to install." 75 40 5 \
        Firefox "" on \
        Konqueror "" on \
        Brave "(AUR)" off \
        Chrome "(AUR)" off \
        2>&1 1>&3))
    exec 3>&-
}

install_browsers () {
    for item in "{$BROWSERS[@]}"
    do
        case $item in 
            # Firefox
            "Firefox")
                pacman -S firefox --noconfirm
                break;;

            "Konqueror")
                pacman -S konqueror --noconfirm
                break;;

            "Brave")
                yay -S brave-bin --noconfirm
                break;;

            "Chrome")
                yay -S google-chrome --noconfirm
                break;;
        esac
    done 
}


##            ##
##  DESKTOPS  ##
##            ##
select_desktops () {
    exec 3>&1
    DESKTOPS=($(dialog --clear --checklist "Use the arrow keys and spacebar to select which desktop environments you would like to install." 75 40 5 \
        "Plasma (Minimal)" "" on \
        "Plasma (Full)" "" off \
        2>&1 1>&3))
    exec 3>&-
}

install_desktops() {
    for item in "{$DESKTOPS[@]}"
    do
        case $item in 
            # Minimal KDE Plasma
            "Plasma (Minimal)")
                echo -e "Installing KDE Plasma desktop..."
                pacman -S plasma-desktop --no-confirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install plasma-desktop. Aborting install..."
                    exit $?
                fi

                # Install basic plasma packages
                echo -e "Installing basic applications for KDE Plasma"
                pacman -S plasma-pa dolphin konsole kdeplasma-addons kde-gtk-config discover kate --noconfirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install basic Plasma apps. Aborting install..."
                    exit $?
                fi
                break;;

            # Full KDE Plasma
            "Plasma (Full)")
                echo -e "Installing Plasma via plasma-meta..."
                pacman -S plasma-meta --no-confirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install plasma-meta. Aborting install..."
                    exit $?
                fi

                # Install plasma applications
                echo -e "Installing KDE applications..."
                pacman -S kde-applications --no-confirm
                if [ $? -ne 0 ]
                then
                    echo "ERROR: Failed to install KDE applications. Aborting install..."
                    exit $?
                fi
                break;;
        esac
    done
}


# Welcome
echo -e "\n\n\n\nWelcome to the Taylor Giles Desktop Environment install script!"
echo -e "IMPORTANT: This script assumes that you have already completed basic installation of Arch Linux."
echo -e "If you have not yet installed Arch, please exit and install Arch now."
echo -e "\n"

read -p "Press [ENTER] to continue..."
echo -e "\n"

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

# Install sddm
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

# Install dialog
echo -e "Installing dialog..."
pacman -S dialog --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install dialog. Aborting install..."
	exit $?
fi

#TODO Install yay/paru


# Make selections
select_desktops()
select_browsers()

# Do installations
install_desktops()
install_browsers()

