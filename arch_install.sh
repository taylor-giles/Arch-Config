# Print out available disk options and save them to array
lsblk -dplnx size -o name,size
DISK_OPTIONS=("${(@f)$(lsblk -dplnx size -o name)}")

# Select disks
PS3="Select the EFI disk: "
select EFI_DISK from $DISK_OPTIONS
do
echo $EFI_DISK
if [-z $EFI_DISK] then
	echo "Please make a valid selection."
else
	break
done

PS3="Select the swap disk: "
select SWAP_DISK from $DISK_OPTIONS
do
echo $SWAP_DISK
if [-z $SWAP_DISK] then
	echo "Please make a valid selection."
else
	break
done

PS3="Select the filesystem disk: "
select FS_DISK from $DISK_OPTIONS
do
echo $FS_DISK
if [-z $FS_DISK] then
	echo "Please make a valid selection."
else
	break
done



