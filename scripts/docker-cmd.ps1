param (
    [string]$task = ""
)

$image_fullname="tizzolicious/openil-base:2.0"
$container_name="nxp-ls1028ardb-bsp"

function Usage 
{
    Write-Output "IMPORTANT: Execute this from within the repository's 'scripts' directory."
    Write-Output "Usage: docker-cmd.ps1 -task [init | bash | stop | remove | start | login ]"
}

if (!$task)
{
    Write-Output "ERROR: '-t' argument must be specified"
    Usage
    exit 1
}

Write-Output "INFO: task is '$task'"

switch ( $task )
{
    init 
    {
        cd ..
        Write-Output "INFO: Pulling the image: ${image_fullname}..."
        docker pull ${image_fullname}
        Write-Output "INFO: Initialize the container. Mapping current working directory '${PWD}' to the connector..."
        docker run --name ${container_name} -i -d --volume ${PWD}:/usr/project/src --entrypoint=/bin/bash ${image_fullname}
        cd scripts
    }
    bash 
    {
        Write-Output "INFO: starting bash in the container..."
        docker exec -it ${container_name} /bin/bash
    }
    stop 
    {
        Write-Output "INFO: Please wait as the container is stopped. This will take a few moments..."
        docker container stop ${container_name}
        Write-Output "INFO: Successfully stopped."
    }
    remove 
    {
        Write-Output "INFO: Please wait as the container is stopped. This will take a few moments..."
        docker container stop ${container_name}
        Write-Output "INFO: Please wait as the container fully removed/deleted..."
        docker container rm ${container_name}
        Write-Output "INFO: Successfully removed."
    }
    start 
    {
        Write-Output "INFO: Please wait as the container is started. This will take a few moments..."
        docker container start ${container_name}
        Write-Output "INFO: Successfully started."
    }
    login 
    {
        docker login registry.gear.ge.com
    }
    default 
    {
        Write-Output "ERROR: Invalid task name '$task'"
        Usage
        exit 1
    }
}



