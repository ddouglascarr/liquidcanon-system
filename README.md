
## Docker containers for 
* core (v3.0.4)
* frontend (v3.0.8)




## Dependencies

* [docker](http://docker.io)  ([Installation Instructions](http://docs.docker.com/mac/started/))
* [docker-compose](https://docs.docker.com/compose/)  ([Installation
  Instructions](https://docs.docker.com/compose/install/))




## Quick Start

* Download / clone this repository.
* In the base directory of this repository ( --demo-data is optional ):
```
    docker-compose run core bootstrap --demo-data
    docker-compose up -d
```
* You should now be able to access the frontend through a web browser at
  [localhost:8080](http://localhost:8080)
* There is an administrator user ("admin") with *no password*. Login and set one.
* You need to set up e-mail to be able to add users, (see below)




## Detailed Start

#### About Docker

There's a good general introdution to docker
[here](http://docs.docker.com/mac/step_two/).

This launches 3 containers: "postgres", "core", "frontend". You can see them by running:
```
  docker ps -a
```
They will have names like "distdocker_frontend_1".
```
CONTAINER ID        IMAGE                           COMMAND                CREATED             STATUS              PORTS                    NAMES
a4e88227f6bb        distdocker_core       "/opt/liquid_feedbac   12 minutes ago      Up 12 minutes                                distdocker_core_1       
306bef597f88        distdocker_frontend   "/run-server.sh"       12 minutes ago      Up 12 minutes       0.0.0.0:8080->8080/tcp   distdocker_frontend_1   
de15b4ed6d17        postgres                        "/docker-entrypoint.   12 minutes ago      Up 12 minutes       5432/tcp                 distdocker_postgres_1  
```

You can see stopped containers as well by running:
```
  docker ps -a
```
If you do this after following instructions in the "Quick Start"
section, there will be a closed container with a name like
"distdocker_core_run_1". This is the bootstrap container and
it is no longer needed. It can be removed by running:
```
  docker rm distdocker_core_run_1
```

To access a root shell on one of the containers run:
```
  docker exec -it distdocker_frontend_1 /bin/bash
```

To stop all the services, run
```
  docker-compose stop
```

To remove the containers and start again, stop them, and run:
```
  docker-compose rm
```
See  the volumes section below regarding persistant database data and configuration files.


#### docker-compose

Docker-compose configuration is all in docker-compose.yml.


#### Volumes

By default, docker-compose mounts volumes in ./volumes.
* *data* is the postgres data directory. If you want to delete
  everything and start again you can delete this directory. (stop the
containers first)
* *ssmtp* is for ssmtp configuration (see the e-mail section
* *frontend_config* is the /opt/liquid_feedback_frontend/config
  directory. You can edit myconfig.lua here.


#### Dockerfiles

By default, docker-compose uses the prebuilt containers from the docker
hub. If you wish to change them, uncomment the "build:" lines in
docker-compose.yml, and comment the "image:" lines. (Leave postgres as
is). To build the images at ./images/image_name run
```
  docker-compse build image_name
```




## Setup E-mail

You need e-mail to be set up to send out new user registrations. This
should be done in the frontend container. 


#### exim4

If you know how to get this working you're smarter than me! Debian has exim4 installed by default, and can be configured with:
```
    $ docker exec -it distdocker_frontend_1 dpkg-dpkg-reconfigure exim4-config
```


#### ssmtp and mandrill

[Mandrill](https://mandrillapp.com) is free (12,000 outgoing messages a month) and relatively easy way to get outgoing e-mails working.

For proper email deliverability, you must set the [SPF and DKIM records](http://help.mandrill.com/entries/21751322-What-are-SPF-and-DKIM-and-do-I-need-to-set-them-up-) in your DNS. In Mandrill, that's under Sending Domains, View DKIM/SPF setup instructions.

* Once you've got an api key (found in mandrill settings), edit the
ssmtp.mandrill.conf file in this repository. 
* Install ssmtp in the frontend container
```
    $ docker exec -it distdocker_frontend_1 apt-get update
    $ docker exec -it distdocker_frontend_1 apt-get install -y ssmtp
```
* Copy the ssmtp.mandrill.conf file to ./volumes/ssmtp/ssmtp.conf (on
  POSIX systems, you may need to be root to do this)
```
   $ cp ssmtp.mandrill.conf ./volumes/ssmtp/ssmtp.conf
```
* Registration should send invite emails now. Check that it does.




## Nginx configuration

Nginx is optional. If you just want to serve the frontend directly,
alter the frontend ports section to "80:8080" and your host will 
serve the site from port 80.

If you do use Nginx, the following location block worked for me.

```
    location / {
        proxy_pass http://localhost:8080/;
        proxy_read_timeout 1m;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

```
