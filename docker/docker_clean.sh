docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

docker rmi $(docker images -q)

docker system prune -af

cd /tmp
sudo rm -rf worker_*
