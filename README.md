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


