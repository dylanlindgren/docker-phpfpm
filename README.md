![Docker + PHP-FPM](https://cloud.githubusercontent.com/assets/6241518/4104985/2f8b00cc-319d-11e4-8a91-94926172392e.jpg)

docker-phpfpm is a CentOS-based docker container for [PHP-FPM](http://php-fpm.org). It is intended for use with [dylanlindgren/docker-nginx](https://github.com/dylanlindgren/docker-nginx).

## Getting the image
This image is published in the [Docker Hub](https://registry.hub.docker.com/). Simply run the below command to get it on your machine:

```bash
docker pull dylanlindgren/docker-phpfpm
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
docker run --privileged=true --name php -v /data/www:/data/www:rw -d dylanlindgren/docker-phpfpm
```
 - `--name` sets the name of the container (useful when starting/stopping, and will be used when launching your Nginx container).
 - `-v` maps the `/data/www` folder as read/write (rw).
 - `-d` runs the container as a daemon
 
**Note:** no need to publish any ports, as we will be using the `--link` switch in our Nginx container, which will make available to Nginx the 9000 port.

To stop the container:
```bash
docker stop php
```

To start the container again:
```bash
docker start php
```
### Running as a Systemd service
To run this container as a service on a [Systemd](http://www.freedesktop.org/wiki/Software/systemd/) based distro (e.g. CentOS 7), create a unit file under `/etc/systemd/system` called `php-fpm.service` with the below contents
```bash
[Unit]
Description=PHP-FPM Docker container (dylanlindgren/docker-phpfpm)
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker stop phpfpm
ExecStartPre=-/usr/bin/docker rm phpfpm
ExecStartPre=-/usr/bin/docker pull dylanlindgren/docker-phpfpm
ExecStart=/usr/bin/docker run --privileged=true --name phpfpm -v /data/www:/data/www:rw dylanlindgren/docker-phpfpm
ExecStop=/usr/bin/docker stop phpfpm

[Install]
WantedBy=multi-user.target
```
Then you can start/stop/restart the container with the regular Systemd commands e.g. `systemctl start php-fpm.service`.

To automatically start the container when you restart enable the unit file with the command `systemctl enable php-fpm.service`.

Something to note is that this service will be depended on by the `nginx.service` setup with [dylanlindgren/docker-nginx](https://github.com/dylanlindgren/docker-nginx).

## Acknowledgements
The below two blog posts were very useful in the creation of both of these projects.

 - [enalean.com](http://www.enalean.com/en/Deploy-%20PHP-app-Docker-Nginx-FPM-CentOSSCL)
 - [stage1.io](http://stage1.io/blog/making-docker-containers-communicate/)
