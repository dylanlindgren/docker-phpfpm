![Docker + PHP-FPM](https://cloud.githubusercontent.com/assets/6241518/4104985/2f8b00cc-319d-11e4-8a91-94926172392e.jpg)

docker-phpfpm is a CentOS-based docker container for [PHP-FPM](http://php-fpm.org). It is intended for use with [dylanlindgren/docker-nginx](https://github.com/dylanlindgren/docker-nginx).

## Getting the image
### Option A: Pull from the Docker Hub
This image is published in the [Docker Hub](https://registry.hub.docker.com/). Simply run the below command to get it on your machine:

```bash
docker pull dylanlindgren/docker-phpfpm
```
### Option B: Build from source
First, `cd` into a directory where you store your Docker repos and clone this repo:

```bash
git clone https://github.com/dylanlindgren/docker-phpfpm.git
```

`cd` into the newly created `docker-phpfpm` directory and build the image (replacing `[IMAGENAME]` in the below command with anything you want to call the image once it's built eg: *dylan/phpfpm*):

```bash
docker build -t [IMAGENAME] .
```

## www data
Website data will be mounted inside the container at `/data/www`. As PHP-FPM looks for website files in the same location as they're requested of Nginx, we will use the `--volumes-from` command when launching the Nginx container to map the website data in the same location. The directory structure will be like below. 
```
/data
|
└────www
     ├─── website1_files
          | ...
     ├─── website2_files
          | ...
```

## Creating and running the container
To create and run the container:
```bash
docker run --privileged=true -p 9000 --name php -v /data/www:/data/www:rw -d dylanlindgren/docker-phpfpm
```
 - `-p` publishes the container's 9000 port to a randomly assigned port number.
 - `--name` sets the name of the container (useful when starting/stopping, and will be used when launching your Nginx container).
 - `-v` maps the `/data/www` folder as read/write (rw).
 - `-d` runs the container as a daemon

To stop the container:
```bash
docker stop php
```

To start the container again:
```bash
docker start php
```
### Running as a Systemd service
To run this container as a service on a [Systemd](http://www.freedesktop.org/wiki/Software/systemd/) based distro (e.g. CentOS 7), create a unit file under `/etc/systemd/system` called `docker-phpfpm.service` with the below contents
```bash
[Unit]
Description=PHP-FPM docker container
After=php-fpm.service docker.service
Requires=php-fpm.service docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop php
ExecStart=/usr/bin/docker start php
ExecStop=/usr/bin/docker stop php

[Install]
WantedBy=multi-user.target
```
Then you can start/stop/restart the container with the regular Systemd commands e.g. `systemctl start docker-phpfpm.service`.

To automatically start the container when you restart enable the unit file with the command `systemctl enable docker-phpfpm.service`.

Something to note is that this service will be depended on by the `docker-nginx.service` setup with [dylanlindgren/docker-nginx](https://github.com/dylanlindgren/docker-nginx).

## Acknowledgements
The below two blog posts were very useful in the creation of both of these projects.

 - [enalean.com](http://www.enalean.com/en/Deploy-%20PHP-app-Docker-Nginx-FPM-CentOSSCL)
 - [stage1.io](http://stage1.io/blog/making-docker-containers-communicate/)
