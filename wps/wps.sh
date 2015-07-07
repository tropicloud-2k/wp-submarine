#!/bin/sh

# WP-SUBMARINE
# ---------------------------------------------------------------------------------
# @author: admin@tropicloud.net
# version: 0.1
# ---------------------------------------------------------------------------------

export user="wordpress"
export home="/home/$user"
export conf="$home/conf"
export www="$home/www"
export env="$home/.env"
export web="$www/web"

if [[  -f $env  ]]; then
for var in `cat $env`; do 
	export $var
done
fi

# FUNCTIONS
# ---------------------------------------------------------------------------------

for f in /wps/bin/*; do
	. $f
done

# COMMANDS
# ---------------------------------------------------------------------------------

  if [[  $1 == 'build'  ]];     then wps_build $@
elif [[  $1 == 'start'  ]];     then wps_start $@
elif [[  $1 == 'stop'  ]];      then wps_stop $@
elif [[  $1 == 'restart'  ]];   then wps_restart $@
elif [[  $1 == 'reload'  ]];    then wps_reload $@
elif [[  $1 == 'shutdown'  ]];  then wps_shutdown $@
elif [[  $1 == 'status'  ]];    then wps_status $@
elif [[  $1 == 'log'  ]];       then wps_log $@
elif [[  $1 == 'ps'  ]];        then wps_ps $@
elif [[  $1 == 'login'  ]];     then wps_login $@
elif [[  $1 == 'root'  ]];      then wps_root $@
elif [[  $1 == 'adminer'  ]];   then wps_adminer $@

# SHELL
# ---------------------------------------------------------------------------------

elif [[  $1 == 'true'  ]];      then /bin/true
elif [[  $1 == 'bash'  ]];      then /bin/bash
elif [[  $1 == '/bin/sh'  ]];   then /bin/sh -c `echo $@ | sed 's|wps sh ||g'`

# HELP
# ---------------------------------------------------------------------------------

else wps_help
fi
