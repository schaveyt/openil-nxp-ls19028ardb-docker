# Build Open Industrial Linux

## 1. Prepare Windows Dev Machine System Requirements

1. Install [Git](https://git-scm.com/downloads)
1. Install [SourceTree](https://www.sourcetreeapp.com/)
1. Install [Docker Desktop for Windows](https://hub.docker.com)
1. `IMPORTANT!` - Update Docker Settings as follows:
   - Enable the Drive mapping to the C:\ drive
   - Increase the Memory to at least 8094
   - Increase the Swap to at least 2048
   - Increase the Disk Space to at least 128GB

## 2. Create the OpenIL Dev Environment Docker Image

~~~bash
cd {repo root dir}/script
chmod 755 ./docker-build-image.sh
./docker-build-image.sh -i openil-base -t 2.0
~~~


## Build OpenIL software images via Docker

1. Ensure you have install the software as specified by the Windows Dev Machine System Requirements section above
1. Clone or download this git repository
1. Open a bash commandline terminal
1. `IMPORTANT` Make your current working directory `{repo root dir}`
1. Initialize the OpenIL Base container

   ~~~bash
   $./script/docker-cmd.ps1 login
   $./script/docker-cmd.ps1 init
   ~~~

1. Enter the OpenIL Base container and build the BSP image

   ~~~bash
   $./script/docker-cmd.ps1 bash
   root@8a77ffd94c7d:/usr/project/src# ./script/build-bsp.sh
   ~~~

   1. Wait about `3 hours`...while it downloads many...many...many artifacts and compiles...

   1. When the script is complete, the last lines of the log will indicate the success of the build.
      - The sdcard.img image is found in the `{repo root dir}/bin` directory

## Load the image for NXP LS1028ARDB

1. Open a bash commandline terminal
1. Make your current working directory `{repo root dir}/bin`
    1. The sdcard.img should be found in this directory.
1. Insert the SD card into the local computer
1. Perform a raw data transfer of the sdcard.img to SD card as follows:
1. Determine which device is the SD card

    ~~~bash
    $ cat /proc/partitions
    major minor  #blocks  name   win-mounts

        8     0  175825944 sda
        8     1  175824896 sda1   C:\
        8    16 1953514582 sdb
        8    17 1953512448 sdb1   E:\
    ~~~

    1. Perform the raw data copy to the SD Card.

    ~~~bash
    $ dd if=./sdcard.img of=/dev/sdb status=progress
    ~~~

    1. When completed, running the Disk Manager program should look like this:

    ![Disk Manager after SD Card Transfer](media/DiskManagmentAfterSDcard.png)
    **Figure - Disk Manager after SD Card Transfer**

    1. Windows should recognize the FAT32 partition and mount it to a drive letter::

    ![Disk Manager after SD Card Transfer](media/D_DriveAfterSDCard.png)
    **Figure - Windows Mounts the FAT32 Parition**


1. Insert the SD card into the LS1028A RDB and reboot
1. From U-Boot,Hit the spacebar key during the boot sequene to enter U-Boot prompt
1. type `qixis_reset sd`
1. Wait...as the os will automatically reboot.
1. The board will load from the SD card and one will see the OpenIL banner from the linux boot sequence.

