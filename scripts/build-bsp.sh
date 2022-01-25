#!/bin/bash

ARGCOUNT=$#
USE_GE_PROXY=1 # default is to use the proxy.
RSYNC_DIR=""
MAKE_CLEAN_SRC=0 # for now, don't always clean and download source files.
REBUILD_ROOTFS=0
REBUILD_PKG=0
REBUILD_PKG_NAME="UNDEFINED"
BSP_VERSION=2020.02.3-326
BSP_SRC_DIR="mscc-brsdk-source-$BSP_VERSION"
BSP_IMG_NAME="mscc-brsdk-arm64-$BSP_VERSION.tar.gz"
BSP_INSTALL_DIR="/opt/mscc/mscc-brsdk-arm64-$BSP_VERSION"
RELEASE="222222-X01"

function usage {
    echo "Usage: build-bsp.sh [options]"
    echo "options"
    echo "--------------------------------------------------------------------------"
    echo "-n            No proxy. Disables use of proxy where its presence causes issues"
    echo "-s            Skip make clean and make source"
    echo "-b            Rebuild all rootfs"
    echo "-p package    Rebuild buildroot package only"
    echo "-r dir        Rsynch a directory with the container's XLDK/$LINUX_PATCHED_DIR "
    echo
}

if [ $ARGCOUNT -ne 0 ]; then

    # error if the first argument does not lead with a '-'
    FIRST_CHAR_OF_ARG="${1:0:1}"
    if [ "$FIRST_CHAR_OF_ARG" != "-" ]; then
        echo "ERROR: '$1' is an invalid argument."
        usage
        exit 1
    fi

    # error if the first argument is only a '-'
    if [ "$1" == "-" ]; then
        echo "ERROR: '$1' is an invalid argument."
        usage
        exit 1
    fi

fi

# Setup commandline argument parsing
while getopts "nsbr:p:" opt; do
  case ${opt} in
    n )
        echo "INFO: GE proxy disabled"
        USE_GE_PROXY=0
        ;;
    r )
        RSYNC_DIR=$OPTARG
        ;;
    s )
        MAKE_CLEAN_SRC=0
        ;;
    b )
        MAKE_CLEAN_SRC=0
        REBUILD_ROOTFS=1
        ;;
    p )
        MAKE_CLEAN_SRC=0
        REBUILD_PKG=1
        REBUILD_PKG_NAME=$OPTARG
        ;;
    \? ) 
        usage
        exit 0
        ;;
    : )
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        usage
        exit 1
        ;;
    * )
        echo "Invalid option: $OPTARG" 1>&2
        usage
        exit 1
        ;;
  esac
done

shift $((OPTIND -1))

base_dir=/usr/project

# these two line is required so that the jenkin pipeline works as well.
pushd .
cd ${base_dir}/src

# set up the environment
if [ $USE_GE_PROXY == 1 ]
then
    echo "INFO: GE Proxy is enabled"
    source ${base_dir}/src/scripts/proxy-on.sh
else
    echo "INFO: GE Proxy is disabled"
fi

cwd=$(pwd)

echo "INFO: Add build information to linux version..."
build_name=""
branch=""

if  [ -z "$BUILD_ID" ]
then
    # Obtain the git branch name
    branch=$(git branch | grep \* | cut -d ' ' -f2)

    BUILD_ID="local"
else
    # Obtain the branch name by using the Jenkins Job name. Trust me.
    # using the git branch command render (detached)
    branch=${JOB_NAME}
fi

# Replace fwd slashes with a dash
branch_scrubbed=$(echo $branch | sed -r 's/\//-/g')

# Replace '%2F' url slashes with a dash
branch_scrubbed=$(echo $branch_scrubbed | sed -r 's/%2F/-/g')

# Replace underscores with dash
branch_scrubbed=$(echo $branch_scrubbed | sed -r 's/_/-/g')

# Remove the name of the repo
branch_scrubbed=$(echo $branch_scrubbed | sed -r 's/nxp-ls1028ardb-//g')

# Set build_name
build_name=${RELEASE}-${branch_scrubbed}-bld-${BUILD_ID}

echo
echo "INFO: Updating Linux Kernel Version with Build Name: ${build_name}"
echo

# Create the output binary directories
#
rm -rf ${base_dir}/src/bin
mkdir -p ${base_dir}/src/bin || exit 1

pushd .
cd /opt/openil

# required to build some items used in buildroot
export FORCE_UNSAFE_CONFIGURE=1

# change the buildroot config to use the config tailored for the iproc-linux
make nxp_ls1028ardb-64b_defconfig || exit 1

if [ $MAKE_CLEAN_SRC == 1 ]
then
    # This will regenerate the .config into the ./output/build_arm64_xstax folder
    # that buildroot make will operate on.
    echo "Calling make clean and source"
    # clean the outputs for fresh starting point
    make clean || exit 1
    # download all the source from the web first then build...
    make source || exit 1
else
    echo "Skipping 'make clean and source'"
fi

if [ $REBUILD_ROOTFS == 1 ] 
then
    echo "Rebuilding buildroot rootfs..."
    rm -rf output/target
    find output/ -name ".stamp_target_installed" |xargs rm -rf
elif [ $REBUILD_PKG == 1 ] 
then
    echo "Rebuilding buildroot package '$REBUILD_PKG_NAME'..."
    make $REBUILD_PKG_NAME-rebuild
fi

# compile the kernel.
make -j2 || exit 1

if [ ! -f "output/images/sdcard.img" ]
then
    echo "ERROR - Build failed! The sdcard.img does not exist in the expected directory"
    exit
fi

echo
echo "INFO: ls -la $(pwd)/output/images"
ls -la output/images/
echo

# Copy the build images to the output directory
#
echo Archive the kernel image...
cp -va output/images/sdcard.img ${base_dir}/src/bin/${build_name}-sdcard.img || exit 1

echo
ls -la ${base_dir}/src/bin
echo

echo "INFO: Success!!! kernel images copied to ${base_dir}/src/bin"
echo

# put the user back in the directory they started from.
popd
