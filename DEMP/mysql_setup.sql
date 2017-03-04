/* Create Database */
CREATE DATABASE database_name_here;

/* Set up grants for the Database */
GRANT ALL PRIVILEGES ON database_name_here.* TO 'mysql_user_here'@'mysql_server' IDENTIFIED BY 'mysql_password_here';

/* Flush Privileges */
FLUSH PRIVILEGES;
