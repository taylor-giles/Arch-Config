#!user/bin/env zsh
# Print out available disk options and save them to array
echo "Available disks:"
lsblk -dplnx size -o name,size
IFS=$'\n\n' DISK_OPTIONS=($(lsblk -dplnx size -o name))

# Select disk
PS3="Please select a disk to partition: "
select CHOSEN_DISK in $DISK_OPTIONS 
do
	if [ -z $CHOSEN_DISK ]
	then
		echo "Please make a valid selection."
	else
		echo "Disk selected: $CHOSEN_DISK"
		break
	fi
done
echo ""



