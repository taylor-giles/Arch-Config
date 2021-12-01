#!/bin/bash
URL="https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/"

full () {
    echo -e "Beginning install process..."
    install
    if [ $? -eq 0 ]; then
        echo "Install script failed. Aborting full installation..."
        exit $?
    fi

    echo -e "Beginning config process..."
    config
    if [ $? -eq 0 ]; then
        echo "Config script failed. Aborting full installation..."
        exit $?
    fi

    echo -e "Beginning DE install process..."
    install_de
    if [ $? -eq 0 ]; then
        echo "DE install script failed. Aborting full installation..."
        exit $?
    fi

    echo -e "\n\n\n\nCongratulations! The full installation process is complete. "
}

install () {
    echo "Getting install script..."
    curl -L "${URL}arch_install.sh" > arch_install.sh
    
    echo "Running install script..."
    chmod +x arch_install.sh
    ./arch_install.sh
    out=$?

    echo "Deleting arch_install.sh script..."
    rm -f arch_install.sh
    return out
}

config () {
	echo "Getting config script..."
	curl -L "${URL}arch_config.sh" > /mnt/arch_config.sh

	echo "Chrooting to run config script..."
	chmod +x /mnt/arch_config.sh
	arch-chroot /mnt ./arch_config.sh $EFI
    out=$?

    # Delete script
    echo "Deleting arch_config.sh script..."
    rm -f /mnt/arch_config.sh
    return out
}

install_de () {
    echo "Getting DE Install script..."
    curl -L "${URL}arch_de_install.sh" > /mnt/arch_de_install.sh

    echo "Chrooting to run DE Install script..."
    chmod +x /mnt/arch_de_install.sh
    arch-chroot /mnt ./arch_de_install.sh
    out=$?

    # Delete script
    echo "Deleting de_install.sh script..."
    rm -f /mnt/arch_de_install.sh
    return out
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

    COLUMNS=1 select ACTION in "Full Install" Install Configure "Install Desktop Environment" Reboot Quit
    do
        case $ACTION in
            # Full Install
            "Full Install")
            full_install
            break
            ;;

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

# Finish
echo -e "\nThank you for using my scripts! :)"