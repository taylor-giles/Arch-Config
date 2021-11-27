# Print out available disk options and save them to array
IFS=$'\n' DISK_OPTIONS=($(lsblk -dplnx size -o name,size))

# Select disks
PS3="Select the EFI disk: "
select EFI_DISK in $DISK_OPTIONS do
	echo $EFI_DISK
	if [-z $EFI_DISK] then
		echo "Please make a valid selection."
	else
		break
done

PS3="Select the swap disk: "
select SWAP_DISK in $DISK_OPTIONS do
	echo $SWAP_DISK
	if [-z $SWAP_DISK] then
		echo "Please make a valid selection."
	else
		break
done

PS3="Select the filesystem disk: "
select FS_DISK in $DISK_OPTIONS do
	echo $FS_DISK
	if [-z $FS_DISK] then
		echo "Please make a valid selection."
	else
		break
done



