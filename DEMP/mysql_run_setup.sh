#!/bin/bash

# Run MySQL, initialise MySQL, and run the Install Script

service mysql start

# Update the mysql_setup script with the environment variable details specified in the Dockerfile.
sed -ie 's/database_name_here/'${APP_DB}'/g' ${working_dir}/.mysql_setup.sql
sed -ie 's/mysql_server/'${MYSQL_ALLOWED_IP}'/g' ${working_dir}/.mysql_setup.sql
sed -ie 's/mysql_user_here/'${APP_USER}'/g' ${working_dir}/.mysql_setup.sql
sed -ie 's/mysql_password_here/'${APP_PASS}'/g' ${working_dir}/.mysql_setup.sql

# Run the mysql_setup.sql to configure the new database permissions.
mysql -u root < ${working_dir}/.mysql_setup.sql

# During the installation the password was not set, here I update the root password with the environment variable, MYSQL_ROOT_PASS, set in the Dockerfile.
mysqladmin -u root password ${MYSQL_ROOT_PASS}

# Seeing that the environment variables contain sensitive information, I decided to unset it here so this can not be obtained. As mentioned in the readme file, this is probably not required as I intend on only using the stack to develop with, but should this be used by someone in a production environment, I'll have the comfort knowing that this is cleared out.
# The unset command does not work for some reason, so I just updated the environment variables with empty values.

export APP_DB= && export MYSQL_ALLOWED_IP= && export APP_USER= && export APP_PASS= && export MYSQL_ROOT_PASS=

# I stop the mysql service here, as I will be instantiating it from supervisord. 
service mysql stop
