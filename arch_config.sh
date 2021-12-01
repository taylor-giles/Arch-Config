#!/bin/bash

# Welcome
echo -e "\n\n\n\nWelcome to the Taylor Giles Arch Configuration script!"
echo -e "IMPORTANT: This script assumes that you have already completed basic installation of Arch Linux."
echo -e "If you have not yet installed Arch, please exit and install Arch now."
echo -e "\n"

read -p "Press [ENTER] to continue..."
echo -e "\n"

# Select region
while true
do
    echo -e "\nAvailable regions:"
    ls /usr/share/zoneinfo/
    read -p "Enter your region: " REGION

    # Validate selection
    [ -d "/usr/share/zoneinfo/$REGION" ] && break || echo -e "Region $REGION not found."
done

# Select city
while true
do
    echo -e "\nAvailable cities in ${REGION}:"
    ls "/usr/share/zoneinfo/$REGION"
    read -p "Enter your city: " CITY

    # Validate selection
    [ -f "/usr/share/zoneinfo/$REGION/$CITY" ] && break || echo -e "City $CITY not found in region $REGION"
done

# Set time zone
echo -e "\nSetting time zone..."
ln -sf "/usr/share/zoneinfo/$REGION/$CITY /etc/localtime"
if [ $? -ne 0 ]
then
	echo -e "ERROR: Time zone set failed. Aborting config..."
	exit $?
fi

# Set hardware clock
echo -e "Setting hardware clock..."
hwclock --systohc
if [ $? -ne 0 ]
then
	echo -e "ERROR: Hardware clock set failed. Aborting config..."
	exit $?
fi

# Add locale
echo -e "Adding en_US.UTF-8 to locales..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to add locale. Aborting config..."
	exit $?
fi

# Generate locales
echo -e "Generating locales..."
locale-gen
if [ $? -ne 0 ]
then
	echo -e "ERROR: locale generation failed. Aborting config..."
	exit $?
fi

# Set hostname
echo -e "\nSet your hostname now."
read -p "Enter the hostname for this computer: " HOSTNAME
echo -e "Setting $HOSTNAME as hostname..."
echo -e "$HOSTNAME" >> /etc/hostname
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to set hostname. Aborting config..."
	exit $?
fi

# Create hosts file
echo -e "Creating hosts file..."
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1	${HOSTNAME}.localdomain     ${HOSTNAME}" >> /etc/hosts

# Set root password
echo -e "\nSet up your root password now."
passwd
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to set root password. Aborting config..."
	exit $?
fi

# Set up users
while true
do
    echo -e ""
    read -p "Would you like to set up another user? [Y/N]" -r CONFIRM
    echo -e ""
    [[ ! $CONFIRM =~ ^[Yy]$ ]] && break

    read -p "Enter the user name for the new user: " USERNAME
    echo -e "Creating new user..."
    useradd -m ${USERNAME}
    if [ $? -ne 0 ]
    then
        echo -e "ERROR: Failed to create new user. Aborting config..."
        exit $?
    fi
    echo -e "\nSet the password for user ${USERNAME} now."
    passwd ${USERNAME}
    if [ $? -ne 0 ]
    then
        echo -e "ERROR: Failed to set password for ${USERNAME}. Aborting config..."
        exit $?
    fi

    # Add user to groups
    echo -e "Adding user $USERNAME to groups..."
    usermod -aG wheel,audio,video,optical,storage ${USERNAME}

    echo -e "User $USERNAME successfully created."
done

# Install sudo
echo -e "Installing sudo..."
pacman -S sudo --noconfirm
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to install sudo. Aborting config..."
	exit $?
fi

# Configure sudoers
echo -e "Configuring sudoers..."
sed -i '/#\s*%wheel ALL=(ALL) ALL$/ c %wheel ALL=(ALL) ALL' /etc/sudoers
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to configure sudoers. Aborting config..."
	exit $?
fi

# Install grub
echo -e "Installing grub and related packages..."
pacman -S grub efibootmgr dosfstools os-prober mtools --noconfirm
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to install grub packages. Aborting config..."
	exit $?
fi

# Create boot directory
echo -e "Creating boot directory..."
mkdir /boot/EFI
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to make boot directory. Aborting config..."
	exit $?
fi

# Get EFI partition from command args or user input
EFI="$1"
if [ -z $EFI ]
then 
	# Print out available partition options and save them to array
    echo -e "\n\n----- Partition Selection -----"
	echo -e "\nAvailable partitions:"
    PARTITION_STRING="$(lsblk -l -o name,size,type | grep part)"
	echo -e "${PARTITION_STRING//part/""}"
    PARTITION_STRING="$(lsblk -l -o name,type | grep part)"
    PARTITION_STRING="${PARTITION_STRING//part/" "}"
    PARTITION_OPTIONS=($PARTITION_STRING)

	# Select EFI partition
	echo -e ""
	PS3="Select the EFI partition to mount boot directory: "
	select EFI_PART in ${PARTITION_OPTIONS[@]} 
	do
		if [ -z $EFI_PART ]
		then
			echo -e "Please make a valid selection."
		else
			echo -e "Partition selected: $EFI_PART"
			break
		fi
	done
    EFI=$(echo -e "/dev/$EFI_PART" | xargs)
fi

# Mount boot partition
echo -e "Mounting boot partition..."
mount $EFI /boot/EFI
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to mount boot directory. Aborting config..."
	exit $?
fi

# Install grub
echo -e "Installing grub (for real this time)..."
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to install grub to partition. Aborting config..."
	exit $?
fi

# Make grub config
echo -e "Generating grub config file..."
grub-mkconfig -o /boot/grub/grub.cfg
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to generate grub config file. Aborting config..."
	exit $?
fi

# Update system
echo -e "Updating system..."
pacman -Syu --noconfirm
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to update system. Aborting config..."
	exit $?
fi

# Install network manager
echo -e "Installing network manager..."
pacman -S networkmanager --noconfirm
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to install networkmanager. Aborting config..."
	exit $?
fi

# Enable network manager
echo -e "Enabling NetworkManager..."
systemctl enable NetworkManager
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to enable NetworkManager. Aborting config..."
	exit $?
fi

# Install base-devel
echo -e "Installing base-devel..."
pacman -S base-devel --noconfirm
if [ $? -ne 0 ]
then
	echo -e "ERROR: Failed to install base-devel. Aborting config..."
	exit $?
fi

# Finish
echo -e "\n\nDone!"
echo -e "Thank you for using my configurator! :)"