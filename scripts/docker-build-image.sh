#!/bin/bash

timestamp=""

function update_timestamp {
    timestamp=$(date '+%Y.%m.%d-%H.%M.%S')
}

function build_image_openil_base {
    echo
    echo "INFO: Building the OpenIL Base Image..."
    docker image build \
        --file Dockerfiles/openil-base.Dockerfile \
        --rm \
        --tag=docker.cherryberrystudio.com/openil-base:$1 . | tee logs/build-image-openil-base.docker.${1}.${timestamp}.log || exit 1
    
    echo
    echo Build log: $(pwd)/logs/build-image-openil-base.docker.${1}.${timestamp}.log
    echo
}

function usage {
    echo ""
    echo "Usage: build-image.sh [-i image-name ] [-t tag-label]"
    echo ""
    echo "Image Names:"
    echo "  openil-base"
    echo ""
}

if [ $? -ne 0 ]
then
    usage
fi

# Setup commandline argument parsing
while getopts ":i:t:" opt; do
  case ${opt} in
    i )
        IMAGE_TARGET=$OPTARG
        ;;
    t )
        TAG_NAME=$OPTARG
        ;;
    \? ) 
        usage
        exit 0
        ;;
    : )
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        exit 1
        ;;
  esac
done
shift $((OPTIND -1))

if [ -z "$IMAGE_TARGET" ]
then
    echo "ERROR: The image target was not specified."
    usage
    exit 1
fi

if [ -z "$TAG_NAME" ]
then
    echo "WARNING: The tag name was not specified. Will default to 'latest'"
    TAG_NAME=latest
fi

echo "INFO: IMAGE_TARGET is '$IMAGE_TARGET'"
echo "INFO: TAG_NAME is '$TAG_NAME'"
echo
echo "INFO: Ensure you have increased the memory and disk space in the Docker settings or this will fail!"
echo

# update the current timestamp
update_timestamp

if [ ! -d logs ]
then
    mkdir -v logs
fi

case $IMAGE_TARGET in
     openil-base)
          build_image_openil_base $TAG_NAME
          ;;
     *)
          echo "ERROR: Invalid image name '$IMAGE_TARGET'"
          usage
          exit 1
          ;;
esac


echo "INFO: Build script completed."
echo
echo "INFO: Run the publish-image.sh to share this image."
echo
