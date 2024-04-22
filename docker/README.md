## Usage

Add *bash docker_runner.sh* before your python command. The script will pass everything followed into the docker. For **Pacman**, you can run a simple game with the following commands. Please run this in your repo's root directory.
```
bash docker/docker_runner.sh
```
And then you can run the game following the instruction. Please use option `-t` to make sure only use `textDisplayer`. You might need to use `-p` options if you want to see the print in terminal, or use `-l` option to save the output into a log file.

You might need to use superuser (adminstrator) access to run this.

## Config

Docker related parameters are included in the docker/docker_config file. If you want to rebuild your image with new requirements.txt, you can switch *force_build* to *1*.

## Debug

You can use the second *docker_cmd* in *docker_runner.sh* to debug in the container. Use *exit* to stop debugging.
