#!/bin/bash

# Welcome
echo -e "\n\n\n\nWelcome to the Taylor Giles Desktop Environment install script!"
echo -e "IMPORTANT: This script assumes that you have already completed basic installation of Arch Linux."
echo -e "If you have not yet installed Arch, please exit and run install Arch now."
echo -e "\n\n\n"

echo -e "Press any key to continue..."
read -k1 -s
echo -e "\n"

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

# Install plasma
echo -e "Installing plasma via plasma-meta..."
pacman -S plasma-meta
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install plasma-meta. Aborting install..."
	exit $?
fi

# Install plasma applications
echo -e "Installing KDE applications..."
pacman -S kde-applications
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install KDE applications. Aborting install..."
	exit $?
fi
