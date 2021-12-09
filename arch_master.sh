#!/bin/bash
URL="https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/"

full_install () {
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

    echo -e "Beginning additional apps install process..."
    install_apps
    if [ $? -eq 0 ]; then
        echo "Apps install script failed. Aborting full installation..."
        exit $?
    fi

    echo -e "\n\n\n\nCongratulations! The full installation process is complete."
    echo -e "It is recommended to reboot your system at this time."
}

install () {
    echo "Getting install script..."
    curl -L "${URL}arch_install.sh" > arch_install.sh
    
    echo "Running install script..."
    chmod +x arch_install.sh
    ./arch_install.sh
    retval=$?

    echo "Deleting arch_install.sh script..."
    rm -f arch_install.sh
    return $retval
}

config () {
	echo "Getting config script..."
	curl -L "${URL}arch_config.sh" > /mnt/arch_config.sh

	echo "Chrooting to run config script..."
	chmod +x /mnt/arch_config.sh
	arch-chroot /mnt ./arch_config.sh $EFI
    retval=$?

    # Delete script
    echo "Deleting arch_config.sh script..."
    rm -f /mnt/arch_config.sh
    return $retval
}

install_apps () {
    echo "Getting Apps Install script..."
    curl -L "${URL}arch_apps_install.sh" > /mnt/arch_apps_install.sh

    echo "Chrooting to run apps install script..."
    chmod +x /mnt/arch_apps_install.sh
    arch-chroot /mnt ./arch_apps_install.sh
    retval=$?

    # Delete script
    echo "Deleting apps_install.sh script..."
    rm -f /mnt/arch_apps_install.sh
    return $retval
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

    COLUMNS=1 
    select ACTION in "Full Install" Install Configure "Install Desktop Environment" Reboot Quit
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

            # More Apps
            "Install More Apps")
            install_apps
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
exit 0
