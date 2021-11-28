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
	./arch_config.sh $EFI
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
timedatectl set-ntp true
if [ $? -ne 0 ]
then
	echo "ERROR: System clock not updated. Aborting install..."
	exit $?
fi

# Set up Partitions
while
do
	select_partitions

	# Confirm choices
	echo "\n\nChosen partitions:\nEFI:        $EFI_PART\nSWAP:       $SWAP_PART\nFILESYSTEM: $FS_PART\n"
	read -q "CONFIRM?Is this correct? ([y] to proceed)" && break || echo "\nRepeating partition selection\n\n"
done

# Add /dev/ and remove whitespace
EFI=$(echo "/dev/$EFI_PART" | xargs)
SWAP=$(echo "/dev/$SWAP_PART" | xargs)
FS=$(echo "/dev/$FS_PART" | xargs)

echo "Creating ext4 file system..."
mkfs.ext4 $FS
if [ $? -ne 0 ]
then
	echo "ERROR: ext4 file system not created. Aborting install..."
	exit $?
fi

echo "Initializing swap..."
mkswap $SWAP
if [ $? -ne 0 ]
then
	echo "ERROR: mkswap failed. Aborting install..."
	exit $?
fi

swapon $SWAP
if [ $? -ne 0 ]
then
	echo "ERROR: swapon failed. Aborting install..."
	exit $?
fi

echo "Formatting EFI partition..."
mkfs.fat -F32 $EFI
if [ $? -ne 0 ]
then
	echo "ERROR: EFI partition not formatted. Aborting install..."
	exit $?
fi

echo "Mounting root volume..."
mount $FS /mnt
if [ $? -ne 0 ]
then
	echo "ERROR: root volume not mounted. Aborting install..."
	exit $?
fi

# Install Base System
echo "Installing base system packages..."
pacstrap /mnt base linux linux-firmware
if [ $? -ne 0 ]
then
	echo "ERROR: Base system package install failed. Aborting install..."
	exit $?
fi

# Move on to config
echo "\n\nBasic installation steps finished."
read -q "CONFIRM?Would you like to continue with configuration? ([y] to proceed)" && config

echo "\nFinished! This file will now self-delete."
echo "\nThank you for using my installer! :)"

# Delete this file
rm -f ${0:a}
