#!/usr/bin/env zsh

# Welcome
clear
echo "*************************************"
echo "**** Welcome to the Taylor Giles ****"
echo "******** Arch Linux Installer *******"
echo "*************************************"
echo "\n\n(Press Ctrl+C at any time to exit the installer.)"
echo "\nIMPORTANT: This installer assumes that you already have EFI, SWAP, and filesystem partitions."
echo "If you do not have these partitions prepared, please exit with Ctrl+C and partition now."

# STEP 1: Set up Partitions
while
do
	echo "\n\n----- Step 1: Set Up Partitions -----"

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

	# Confirm choices
	echo "\n\nChosen partitions:\nEFI:        $EFI_PART\nSWAP:       $SWAP_PART\nFILESYSTEM: $FS_PART\n"
	read -q "CONFIRM?Is this correct? ([y] to proceed)" && break || echo "Repeating partition selection\n\n"
done



