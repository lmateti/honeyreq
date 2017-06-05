# honeyreq
On demand research honeypot with Nginx, OpenResty, Docker and Wordpress

## Prerequesets
Work was done on Ubuntu operating system; there is no garantee that it will work on other systems.
1. Install [OpenResty](https://openresty.org/en/installation.html)
2. Install [Docker](https://docs.docker.com/engine/installation/)
- Download [Official Wordpress image](https://hub.docker.com/_/wordpress/)
- Download [Official MySQL image](https://hub.docker.com/_/mysql/)

## Configuration
1. Setting up virtual network (common interface names: eth0, eth1, enp2s0...)

sudo ip addr add 10.0.0.1/8 dev enp2s0

sudo ip addr add 10.0.0.2/8 dev enp2s0 

sudo ip addr add 10.0.0.3/8 dev enp2s0

sudo ip addr add 10.0.2.1/8 dev enp2s0

sudo ip addr add 192.168.43.202 dev enp2s0

2. Setting up Docker images

sudo docker run -p 10.0.0.1:3306:3306 --name production-mysql -e MYSQL_ROOT_PASSWORD=mysecpas -d mysql:latest

sudo docker run -p 10.0.0.2:3306:3306 --name honeypot1-mysql -e MYSQL_ROOT_PASSWORD=mysecpas -d mysql:latest

sudo docker run -p 10.0.0.3:3306:3306 --name honeypot2-mysql -e MYSQL_ROOT_PASSWORD=mysecpas -d mysql:latest

sudo docker run -p 10.0.2.1:3333:80 --name production-wordpress --link produkcijski-mysql:mysql -d wordpress

sudo docker run -p 10.0.2.1:3666:80 --name honeypot1-wordpress --link honeypot1-mysql:mysql -d wordpress

sudo docker run -p 10.0.2.1:3999:80 --name honeypot2-wordpress --link honeypot2-mysql:mysql -d wordpress

3. Manually go to each Wordpress address and set 

![alt text](https://raw.githubusercontent.com/lmateti/honeyreq/master/Wordpress.png)
