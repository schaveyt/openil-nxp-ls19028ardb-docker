#!/bin/bash

image_fullname="tizzolicious/openil-base:2.0"
container_name="nxp-ls1028ardb-bsp"


function usage {
    echo "IMPORTANT: Execute this from within the repository's 'scripts' directory."
    echo "Usage: docker-cmd.sh -t [init | bash | stop | remove | start | login ]"
}


if [ $? -ne 0 ]
then
    usage
fi

# Setup commandline argument parsing
while getopts "t:" opt; do
  case ${opt} in
    t )
        TASK=$OPTARG
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

if [ -z "$TASK" ]
then
    echo "ERROR: The image target was not specified."
    usage
    exit 1
fi


echo "INFO: TASK is '$TASK'"
echo

case $TASK in
        init)
            cd ..
            echo "INFO: Pulling the image: ${image_fullname}..."
            docker pull ${image_fullname}
            echo "INFO: Initialize the container. Mapping current working directory '${PWD}' to the connector..."
            docker run --name ${container_name} -i -d --volume ${PWD}:/usr/project/src --entrypoint=/bin/bash ${image_fullname}
            ;;
        bash)
            docker exec -it ${container_name} /bin/bash
            ;;
        stop)
            echo "INFO: Please wait as the container is stopped. This will take a few moments..."
            docker container stop ${container_name}
            echo "INFO: Successfully stopped."
            ;;
        remove)
            echo "INFO: Please wait as the container is stopped. This will take a few moments..."
            docker container stop ${container_name}
            echo "INFO: Please wait as the container fully removed/deleted..."
            docker container rm ${container_name}
            echo "INFO: Successfully removed."
            ;;
        start)
            echo "INFO: Please wait as the container is started. This will take a few moments..."
            docker container start ${container_name}
            echo "INFO: Successfully started."
            ;;  
        login)
            docker login registry.gear.ge.com
            ;;
        *)
            echo "ERROR: Invalid task name '$TASK'"
            usage
            exit 1
            ;;
esac



