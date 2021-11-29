#!/bin/bash
URL="https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/"

install () {
    echo "Getting install script..."
    curl -L "${URL}arch_install.sh" > arch_install.sh
    
    echo "Running install script..."
    chmod +x arch_install.sh
    ./arch_install.sh
}

config () {
	echo "Getting config script..."
	curl -L "${URL}arch_config.sh" > /mnt/arch_config.sh

	echo "Chrooting to run config script..."
	chmod +x /mnt/arch_config.sh
	arch-chroot /mnt ./arch_config.sh $EFI
}

# Welcome
clear
echo -e "\n\n************************************"
echo -e "********** Welcome to the **********"
echo -e "******* Arch Linux Assistant *******"
echo -e "********** by Taylor Giles *********"
echo -e "************************************\n"

echo -e "Please select your desired action:"

select ACTION in Install Configure Reboot Quit
do
    case $os in
        # Install
        "Install")
        install
        ;;

        # Config
        "Configure")
        config
        ;;

        # Quit
        "Quit")
        break
        ;;
    esac
done

#Finish
echo -e "\nThank you for using my script! :)"