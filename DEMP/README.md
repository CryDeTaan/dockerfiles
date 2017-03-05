<h1>Docker Nginx MySQL PHP-FPM (DEMP) Stack</h1>

I wanted a linux based development stack that I can run on Windows. I was not happy with some of the available stacks that can run on Windows, for example MAMP or WAMP. So I decided to build a single docker container running Nginx, MySQL and PHP-FPM which can give me I similar experience to what I would have when developing on macOS.

It can be used with any sort of development framework, I'll be using laravel. All that is required is for the volume to be mapped to where the project will run from.

<h2> I will explain each process here:</h2>

<h3>Supervisor</h3>
I want to start with supervisor. 
A Docker container can only runs a single process when it is launched; Often though you want to run more than one process in a container.
There are a number of ways to achieve this however I will instantiate a simple Bash script from CMD instruction to a process control tool, called supervisord, which spawns each process with its own pid. 
Its important that this file can not be modified by any user, as this will allow executing commands as root. I gave this configuration file permissions of 600 to root only. 

<h3>Nginx</h3>
I decided on Nginx as the web server, non other reason than; I prefer it over Apache.
The nginx_vhost.conf file will be copied to /etc/nginx/conf.d/ which is Nginx loads on start.
This config file specifies that the web root in the container is /var/www/html. I will use the docker volume to map to this directory from the host. 

<h3>PHP-FPM</h3>
Only thing that is required to get php running in the container is to created the directory for the PHP-FPM Sock to live in. The location in the default php.ini uses /run/php and is good enough for the purposes of this container.

<h3>MySQL</h3>
MySQL was by var the most challenging to get integrated into the same docker image. But this is how I did it.
During the installation of mysql, it is required to provide a password, I actually suppress that by adding the following in the Dockerfile:

`ENV  DEBIAN_FRONTEND noninteractive`

`RUN echo "mysql-server mysql-server/root_password password" | debconf-set-selections`

`RUN echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections`

This means that there is no password set for the root user. I will fix this in the mysql_run_setup script by updating the root password using the environment variable MYSQL_ROOT_PASS.

I also decided, in the default configuration, to add a database and assign a specific user with password to the new database. This is done by taking the environment variables and updating the values of the dummy data in the mysql_setup.sql file. However MySQL is not yet started, so in the mysql_run_setup.sh I start the database, sed the new values into the mysql_setup.sql file, run the .sql file and stop the database. This prepares the database with the given values. There is no reason that the environment variables cannot be updated with the permissions to grant the root user remote access to all databases.

Some cleanup I decided to do was, to remove the mysql_setup.sql file which has the passwords stored for the sake of the setup, and I also unset the environment variables so that these cannot be obtained later by unintended users. I know this is probably not necessary, as I am only intending to use this as a development environment, I though should someone decide to use this in a production environment of sorts, this security "feature" would at least have been implemented. 

<h2>Usage:</h2>
<h3>Creat the DEMP docker image</h3>
`docker build -t demp .`

<h3>Run the DEMP docker image</h3>
`docker run -d -h demp -v /Users/CryDeTaan/Desktop/DockerStuff/webroot:/var/www/html  -p 80:80 -p 3306:3306 --name demp demp`

Note on -v (volumes) for mac and windows:

If you are using Docker Machine on Mac or Windows, your Docker Engine daemon has only limited access to your macOS or Windows filesystem. Docker Machine tries to auto-share your /Users (macOS) or C:\Users (Windows) directory. So, you can mount files or directories on macOS using.

```docker run -v /Users/<path>:/<container path> ...```

On Windows, mount directories using:

```docker run -v //c/<path>:/<container path>```

<h3>Execute a command on the running DEMP docker image</h3>
`docker exec -it demp /bin/bash`

