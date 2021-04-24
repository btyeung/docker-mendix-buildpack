#!/bin/bash

#set defaults
PROJECT_NAME='output.mda'

#expect one parameter (filename)
if [ $# -eq 0 ]
    then
        echo "Expecting project name as first parameter, defaulting to output.mda"        
    else
        PROJECT_NAME=${1}
fi

ID=$(docker create mx-build:latest)
echo "Docker container created with ID of" $ID

#extract mda file from container, write to local filesystem
#TODO: remove .mpk if its present
docker cp "${ID}:/tmp/model.mda" "${PROJECT_NAME}.mda"  

#remove container
docker rm -v $ID
echo "Docker container of ${ID} removed"
