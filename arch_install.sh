#!/usr/bin/env zsh

# Define partition selection function
select_partitions () {
	echo "\n\n----- Partition Selection -----"

	# Print out available partition options and save them to array
	echo "\nAvailable partitions:"
	echo "${$(lsblk -l -o name,size,type | grep part)//part/""}"
	PARTITION_OPTIONS=(${(f)"${$(lsblk -l -n -o name,type | grep part)//part/" "}"})

	# Select EFI partition
	echo "\n"
	PS3="Select the EFI partition: "
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

	# Select SWAP partition
	echo "\n"
	PS3="Select the SWAP partition: "
	select SWAP_PART in $PARTITION_OPTIONS 
	do
		if [ -z $SWAP_PART ]
		then
			echo "Please make a valid selection."
		else
			echo "Partition selected: $SWAP_PART"
			break
		fi
	done

	# Select FS partition
	echo "\n"
	PS3="Select the FILESYSTEM partition: "
	select FS_PART in $PARTITION_OPTIONS 
	do
		if [ -z $FS_PART ]
		then
			echo "Please make a valid selection."
		else
			echo "Partition selected: $FS_PART"
			break
		fi
	done
}

# Define config function
config () {
	echo "Getting config script..."
	curl -L https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/arch_config.sh > arch_config.sh

	echo "Starting config script..."
	chmod +x arch_config.sh
	./arch_config.sh
}

# Welcome
clear
echo "\n\n*************************************"
echo "**** Welcome to the Taylor Giles ****"
echo "******** Arch Linux Installer *******"
echo "*************************************"
echo "\n\n(Press Ctrl+C at any time to exit the installer.)"
echo "\nIMPORTANT: This installer assumes that you already have EFI, SWAP, and filesystem partitions."
echo "If you do not have these partitions prepared, please exit with Ctrl+C and partition now."

# Update clock
echo "\nUpdating system clock..."
timedatectl set-nt p true

# Set up Partitions
while
do
	select_partitions

	# Confirm choices
	echo "\n\nChosen partitions:\nEFI:        $EFI_PART\nSWAP:       $SWAP_PART\nFILESYSTEM: $FS_PART\n"
	read -q "CONFIRM?Is this correct? ([y] to proceed)" && break || echo "\nRepeating partition selection\n\n"
done

echo "Creating ext4 file system..."
mkfs.ext4 $"/dev/$FS_PART"

echo "Initializing swap..."
mkswap $"/dev/$SWAP_PART"
swapon $"/dev/$SWAP_PART"

echo "Formatting EFI partition..."
mkfs.fat -F32 $"/dev/$EFI_PART"

echo "Mounting root volume..."
mount $"/dev/$FS_PART" /mnt

# Install Base System
echo "Installing base system packages..."
pacstrap /mnt base linux linux-firmware

# Move on to config
echo "\n\nBasic installation steps finished."
read -q "CONFIRM?Would you like to continue with configuration? ([y] to proceed)" && config

echo "\nFinished! This file will now self-delete."
echo "\nThank you for using my installer! :)"

# Delete this file
rm -f ${0:a}
