#!/usr/bin/env zsh

# Welcome
echo "\n\n\n\nWelcome to the Taylor Giles Arch Configuration script!"
echo "\n(Press Ctrl+C at any time to exit the script.)"
echo "\nIMPORTANT: This script assumes that you have already completed basic installation of Arch Linux."
echo "If you have not yet installed Arch, please exit with Ctrl+C and run arch_install.sh now."
echo "\n\n\n"

echo "Press any key to continue..."
read -k1 -s
echo "\n"

# Generate file system table
echo "Generating file system table..."
genfstab -U /mnt >> /mnt/etc/fstab
if [ $? -ne 0 ]
then
	echo "ERROR: fstab generation failed. Aborting config..."
	exit $?
fi

# Chroot into system
echo "Chrooting..."
arch-chroot /mnt
if [ $? -ne 0 ]
then
	echo "ERROR: chroot failed. Aborting config..."
	exit $?
fi

# Select region
while
do
    echo "\nAvailable regions:"
    ls /usr/share/zoneinfo/
    read -p "\nEnter your region: " REGION
    if grep -q $REGION "/usr/share/zoneinfo/"; then
        break
    else 
        echo "Region $REGION not found."
    fi
done

# Select city
while
do
    echo "\nAvailable cities in ${REGION}:"
    ls "/usr/share/zoneinfo/$REGION"
    read -p "\nEnter your city: " city
    if grep -q $CITY "/usr/share/zoneinfo/$REGION"; then
        break
    else 
        echo "City $CITY not found in region $REGION"
    fi
done

# Set time zone
echo "\nSetting time zone..."
ln -sf "/usr/share/zoneinfo/$REGION/$CITY /etc/localtime"
if [ $? -ne 0 ]
then
	echo "ERROR: Time zone set failed. Aborting config..."
	exit $?
fi

# Set hardware clock
echo "Setting hardware clock..."
hwclock --systohc
if [ $? -ne 0 ]
then
	echo "ERROR: Hardware clock set failed. Aborting config..."
	exit $?
fi

# Add locale
echo "Adding en_US.UTF-8 to locales..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to add locale. Aborting config..."
	exit $?
fi

# Generate locales
echo "Generating locales..."
locale-gen
if [ $? -ne 0 ]
then
	echo "ERROR: locale generation failed. Aborting config..."
	exit $?
fi

# Set hostname
echo "Set your hostname now."
read -p "Enter the hostname for this computer: " HOSTNAME
echo "Setting $HOSTNAME as hostname..."
echo "$HOSTNAME" >> /etc/hostname
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to set hostname. Aborting config..."
	exit $?
fi

# Create hosts file
echo "Creating hosts file..."
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1	${HOSTNAME}.localdomain     ${HOSTNAME}" >> /etc/hosts

# Set root password
echo "Set up your root password now."
passwd
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to set root password. Aborting config..."
	exit $?
fi

# Set up users
while
do
    read -q "CONFIRM?\nWould you like to set up another user? ([y] to proceed)" && echo "\n" || break
    read -p "Enter the user name for the new user: " USERNAME
    echo "Creating new user..."
    useradd -m ${USERNAME}
    if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to create new user. Aborting config..."
        exit $?
    fi
    echo "\nSet the password for user ${USERNAME} now."
    passwd ${USERNAME}
    if [ $? -ne 0 ]
    then
        echo "ERROR: Failed to set password for ${USERNAME}. Aborting config..."
        exit $?
    fi

    # Add user to groups
    echo "Adding user $USERNAME to groups..."
    usermod -aG wheel,audio,video,optical,storage ${USERNAME}

    echo "User $USERNAME successfully created."
done

# Install sudo
echo "Installing sudo..."
pacman -S sudo --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install sudo. Aborting config..."
	exit $?
fi

# Configure sudoers
echo "Configuring sudoers..."
sed -i '/#\s*%wheel ALL=(ALL) ALL$/ c %wheel ALL=(ALL) ALL' /etc/sudoers
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to configure sudoers. Aborting config..."
	exit $?
fi

# Install grub
echo "Installing grub and related packages..."
pacman -S grub efibootmgr dosfstools os-prober mtools --noconfirm
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install grub packages. Aborting config..."
	exit $?
fi

# Create boot directory
echo "Creating boot directory..."
mkdir /boot/EFI
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to make boot directory. Aborting config..."
	exit $?
fi

# Get EFI partition from command args or user input
EFI="$1"
if [ -z $EFI ]
then 
	# Print out available partition options and save them to array
	echo "\nAvailable partitions:"
	echo "${$(lsblk -l -o name,size,type | grep part)//part/""}"
	PARTITION_OPTIONS=(${(f)"${$(lsblk -l -n -o name,type | grep part)//part/" "}"})

	# Select EFI partition
	echo "\n"
	PS3="Select the EFI partition to mount boot directory: "
	select EFI_PART in $PARTITION_OPTIONS 
	do
		if [ -z $EFI_PART ]
		then
			echo "Please make a valid selection."
		else
			echo "Partition selected: $EFI_PART"
			break
		fi
	done
    EFI=$(echo "/dev/$EFI_PART" | xargs)
fi

# Mount boot partition
echo "Mounting boot partition..."
mount $EFI /boot/EFI
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to mount boot directory. Aborting config..."
	exit $?
fi

# Install grub
echo "Installing grub (for real this time)..."
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to install grub to partition. Aborting config..."
	exit $?
fi

# Make grub config
echo "Generating grub config file..."
grub-mkconfig -o /boot/grub/grub.cfg
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to generate grub config file. Aborting config..."
	exit $?
fi

echo "\n\nDone! Thank you for using my configurator! :)"