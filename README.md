# honeyreq
On demand research honeypot with Nginx, OpenResty, Docker and Wordpress

## Prerequesets
Work was done on Ubuntu operating system; there is no garantee that it will work on other systems.
1. Install [OpenResty](https://openresty.org/en/installation.html)
2. Install [Docker](https://docs.docker.com/engine/installation/)
- Download [Official Wordpress image](https://hub.docker.com/_/wordpress/)
- Download [Official MySQL image](https://hub.docker.com/_/mysql/)
3. Put checkLoginCred.lua into lua OpenResty folder.
4. Put nginx.conf into OpenResty Nginx conf folder.

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

3. Wordpress configuration for being behind reverse proxy

Go to each Wordpress transport address in your browser (10.0.2.1:33333, 10.0.2.1:3666, 10.0.2.1:3999) 
and install them using famous 5 minute Wordpress installation. Remember username/password for each Wordpress instance that you choose!
Now change Wordpress Address and Site Address to 192.168.43.202.
Once you do that, you should get an error.
That is OK because you shouldn't be able to access Wordpress site directly any longer (that's the point of reverse proxying)

If you think you made a mistake or can't remember password (example: honeypot1-wordpress), simply do the following:
sudo docker stop honeypot1-wordpress honeypot1-mysql
sudo docker rm honeypot1-wordpress honeypot1-mysql
... repeat the docker run commands for setting them up again ...

![alt text](https://raw.githubusercontent.com/lmateti/honeyreq/master/Wordpress.png)

4. Now stop all images besides the production ones (the point is to dinamically start up honeypots on demand):

sudo docker stop honeypot1-wordpress honeypot1-mysql honeypot2-wordpress honeypot2-mysql

5. Allow Lua script to access Docker sock (prototype only!):

sudo chmod o+rwx /var/run/docker.sock

6. Start up Nginx (OpenResty) and access the production/honeypot environments on 192.168.43.202 (even on LAN from other machine)

## How to repeat tests after machine restart
1. Setting up virtual network (common interface names: eth0, eth1, enp2s0...)

sudo ip addr add 10.0.0.1/8 dev enp2s0

sudo ip addr add 10.0.0.2/8 dev enp2s0 

sudo ip addr add 10.0.0.3/8 dev enp2s0

sudo ip addr add 10.0.2.1/8 dev enp2s0

sudo ip addr add 192.168.43.202 dev enp2s0

2. Setting up Docker images

sudo docker start production-mysql

sudo docker start honeypot1-mysql

sudo docker start honeypot2-mysql

sudo docker start production-wordpress

sudo docker start honeypot1-wordpress

sudo docker start honeypot2-wordpress

3. Now stop all images besides the production ones (the point is to dinamically start up honeypots on demand):

sudo docker stop honeypot1-wordpress honeypot1-mysql honeypot2-wordpress honeypot2-mysql

4. Allow Lua script to access Docker sock (prototype only!):

sudo chmod o+rwx /var/run/docker.sock

5. Start up Nginx (OpenResty) and access the production/honeypot environments on 192.168.43.202 (even on LAN from other machine)
