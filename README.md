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


## 3. Build Image for Specifc Board

Build instructions for specific boards are as follows:

- [NXP LS1028ARDB](docs/howto-build-ls1028ardb.md)

