#!/bin/bash

source docker/docker_config

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

current_path=(${PWD})


docker_path='/home/code'


if [ ${machine} == MinGw ]
then
    current_path=(/${PWD})
fi

echo ${current_path}


res=`docker image inspect ${image_name}:${image_tag}`


if [ ${#res} == 2 ] || [ ${force_build} == 1 ]
then
    docker image rm ${image_name}:${image_tag} 
    docker build -f docker/Dockerfile -t ${image_name}:${image_tag} .

    echo ""
    echo "--------------------"
    echo "image built"
    echo "--------------------"
    echo ""
else

    echo ""
    echo "--------------------"
    echo "image exists"
    echo "--------------------"
    echo ""
fi

echo "CPU limit: ${CPU_limit}"
echo "RAM limit: ${CPU_limit}"

# please ignore the error message. This is just incase the contianer is still there
docker container rm ${container_name}

# docker_cmd="docker run -it --rm --cpus=${CPU_limit} --memory=${RAM_limit} --name ${container_name} -v ${current_path}:${docker_path} -w /${docker_path} ${image_name}:${image_tag} $*"

#for debugging: showing the bash window directly
# docker_cmd="docker run -it --rm --cpus=${CPU_limit} --memory=${RAM_limit} --name ${container_name} -v ${current_path}:${docker_path} -w /${docker_path} ${image_name}:${image_tag} bash"

# docker_cmd="docker run -it --rm --cpus=${CPU_limit} --memory=${RAM_limit} --name ${container_name} -v ${current_path}:${docker_path} -w /${docker_path} ${image_name}:${image_tag} bash"
# docker_cmd="docker build -f docker/Dockerfile -t ${image_name}:${image_tag} ."
# sudo docker build -f docker/Dockerfile -t ${image_name}:${image_tag}

# echo $docker_cmd
# eval $docker_cmd


exit
