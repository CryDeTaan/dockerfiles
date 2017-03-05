#!/bin/sh

# Run the MySQL setup script 
chmod +x ${working_dir}/.mysql_run_setup.sh
${working_dir}/.mysql_run_setup.sh

# Once I am done with these files, I'd prefer if they are removed as this contains sensitive details of the internal setup of MySQL. 

rm -f ${working_dir}/.mysql*

# This script will launch the process manager tool and instantiate the processes within the container with each process running in its own pid
/usr/bin/supervisord -n -c ${supervisor_conf}
