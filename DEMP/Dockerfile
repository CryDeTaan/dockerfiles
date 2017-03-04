#
#
# Docker Nginx MySQL PHP-fpm (DEMP) Stack on Ubuntu 16.04
# Date: 04/03/2017
# 
#

# Downloads and use base image of Ubuntu 16.04 
FROM ubuntu:16.04

LABEL Maintainer "CryDeTaan"

#############################
# Set Environment Variables #
#############################

### Global ###
# Working Directory
ENV working_dir /working_dir

# Defining environment variables for configuration files

### Nginx ###
ENV nginx_vhost /etc/nginx/conf.d/nginx_vhost.conf
ENV nginx_conf /etc/nginx/nginx.conf
ENV nginx_webroot /var/www/html

### PHP ###
ENV php_conf /etc/php/7.0/fpm/php.ini
ENV php_sock /run/php

### MySQL ###

# Configuration files
ENV mysql_conf /etc/mysql/mysql.conf.d/mysqld.cnf

# Database configuration
ENV APP_DB testapp
ENV APP_USER testuser
ENV APP_PASS testpass
ENV MYSQL_ALLOWED_IP 172.17.%.%
ENV MYSQL_PASS JustWhatYouWant

### Supervisord ####
ENV supervisor_conf /etc/supervisor/supervisord.conf

##################################
# Prerequisites for installation #
##################################

# Requirements for interactive MySQL installation
ENV  DEBIAN_FRONTEND noninteractive
RUN echo "mysql-server mysql-server/root_password password" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password" | debconf-set-selections

# Update Ubuntu Software repository before installation of the stack
RUN apt-get update >/dev/null

################
# Installtions #
################

# Install nginx, php-fpm, mysql-server and supervisord from ubuntu repository
RUN apt-get install -y \
        supervisor \
        nginx \
        php-fpm \
        php-mysql \
        mysql-server \
        vim \
        >/dev/null

#########################
# Post install cleanups #
#########################

# Clear out the Ubuntu repository list "cache"

RUN rm -rf /var/lib/apt/lists/*

######################
# Add required files #
######################

# Add working directory 
RUN mkdir ${working_dir}

# Application configuration files
COPY nginx_vhost.conf ${nginx_vhost}
COPY supervisord.conf ${supervisor_conf}

# Applcation configuration/setup scripts

COPY mysql_run_setup.sh ${working_dir}/.mysql_run_setup.sh
COPY mysql_setup.sql ${working_dir}/.mysql_setup.sql

# initialisation script that will be run to start the container
COPY __init__.sh ${working_dir}/__init__.sh

##########################################
# Configure/Set application requirements #
##########################################

### Nginx ###
# Disable the nginx daemon, will be handled by supervisord
RUN echo "\ndaemon off;" >> ${nginx_conf}
# Remove default vhost directory
RUN sed -ie 's/include \/etc\/nginx\/sites-enabled\/\*;/#include \/etc\/nginx\/sites-enabled\/\*;/g' ${nginx_conf}
# Update permissions for the web root directory
RUN chown -R www-data:www-data ${nginx_webroot}

### PHP ###
# Set the PHP cgi.fix_pathinfo flag
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${php_conf}
# Create the directory required form the php-fpm sock to reside and update required permissions
RUN mkdir -p ${php_sock}
RUN chown -R www-data:www-data ${php_sock}

### MySQL ###
# Allow connections to be made to the database from outside of the container
RUN sed -i 's/127.0.0.1/'0.0.0.0'/g' ${mysql_conf}

VOLUME /var/lib/mysql

##########################################################
# Expose required port and execute initialisation script #
##########################################################

# Expose the port that nginx will use as the web server
EXPOSE 80 3306

# Run the script that was copied
CMD ${working_dir}/__init__.sh
# EOF #
