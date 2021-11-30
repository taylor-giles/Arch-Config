#!/bin/bash
URL="https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/"

install () {
    echo "Getting install script..."
    curl -L "${URL}arch_install.sh" > arch_install.sh
    
    echo "Running install script..."
    chmod +x arch_install.sh
    ./arch_install.sh

    echo "Deleting arch_install.sh script..."
    rm -f arch_install.sh
}

config () {
	echo "Getting config script..."
	curl -L "${URL}arch_config.sh" > /mnt/arch_config.sh

	echo "Chrooting to run config script..."
	chmod +x /mnt/arch_config.sh
	arch-chroot /mnt ./arch_config.sh $EFI

    # Delete script
    echo "Deleting arch_config.sh script..."
    rm -f /mnt/arch_config.sh
}

install_de () {
    echo "Getting DE Install script..."
    curl -L "${URL}de_install.sh" > /mnt/de_install.sh

    echo "Chrooting to run DE Install script..."
    chmod +x /mnt/de_install.sh
    arch-chroot /mnt ./de_install.sh

    # Delete script
    echo "Deleting de_install.sh script..."
    rm -f /mnt/de_install.sh
}

clear
while true
do
    # Welcome
    echo -e "\n\n\n\n\n************************************"
    echo -e "********** Welcome to the **********"
    echo -e "******* Arch Linux Assistant *******"
    echo -e "********** by Taylor Giles *********"
    echo -e "************************************\n"

    echo -e "Please select your desired action:"

    select ACTION in Install Configure "Install Desktop Environment" Reboot Quit
    do
        case $ACTION in
            # Install
            "Install")
            install
            break
            ;;

            # Config
            "Configure")
            config
            break
            ;;

            # DE
            "Install Desktop Environment")
            install_de
            break
            ;;

            #Reboot
            "Reboot")
            reboot
            break
            ;;

            # Quit
            "Quit")
            echo -e "\nThank you for using my script! :)"
            exit 0
            ;;

            # Default
            *)
            echo -e "\nPlease make a valid selection."
            break
            ;;
        esac
    done
done

#Finish
echo -e "\nThank you for using my scripts! :)"