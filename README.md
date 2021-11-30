# Arch Installation Scripts
by Taylor Giles

## Pre-Setup
These scripts can be used to automatically install Arch Linux, configure the system, and install additional packages.
However, the system must have the appropriate disk partitions prior to running the scripts. Currently, the scripts are configured for systems with an EFI partition, a SWAP partition, and a FILESYSTEM partition. To configure your system in this manner, follow the Arch Wiki Installation Guide for partitioning drives (for example, using `fdisk`).


## Usage
Once your partitions are set up, the best way to use these scripts is by running the following commands:

```
  curl -L https://raw.githubusercontent.com/taylor-giles/Arch-Config/master/arch_master.sh > arch_master.sh
  chmod +x arch_master.sh
  ./arch_master.sh
```

To fully install Arch Linux, configure the system, and install a desktop environment, choose the "Full Install" option from the main menu.

Answer the command-line prompts whenever they appear, such as for choosing appropriate disk partitions or choosing the hostname for the system.

NOTE: The "master" script will automatically install and delete the other scripts in this repository as needed.
