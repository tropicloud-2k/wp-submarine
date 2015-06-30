
wps_env() {

# MYSQL 
# ---------------------------------------------------------------------------------

	if [[ -z $DB_HOST ]] && [[ -z $DB_USER ]] && [[ -z $DB_NAME ]] && [[ -z $DB_PASSWORD ]]; then
		if [[  -z $MYSQL_PORT  ]]; then
		
			export WPS_MYSQL="127.0.0.1:3306"
			export DB_HOST=`echo $WPS_MYSQL | cut -d: -f1`
			export DB_PORT=`echo $WPS_MYSQL | cut -d: -f2`
			export DB_USER="$user"
			export DB_NAME="$user"
			export DB_PASSWORD=`openssl rand -hex 12`
		
		elif [[  -n $MYSQL_PORT  ]]; then 
			
			export WPS_MYSQL=`echo $MYSQL_PORT | cut -d/ -f3`
			export DB_HOST=`echo $WPS_MYSQL | cut -d: -f1`
			export DB_PORT=`echo $WPS_MYSQL | cut -d: -f2`
			
			if [[  -n $MYSQL_ENV_MYSQL_USER  ]];
			then export DB_USER="$MYSQL_ENV_MYSQL_USER"
			else export DB_USER=`echo ${HOSTNAME//./_} | cut -c 1-16`
			fi
			
			if [[  -n $MYSQL_ENV_MYSQL_PASSWORD  ]];
			then export DB_PASSWORD="$MYSQL_ENV_MYSQL_PASSWORD"
			else export DB_PASSWORD=`openssl rand -hex 12`
			fi
			
			if [[  -n $MYSQL_ENV_MYSQL_NAME  ]];
			then export DB_NAME="$MYSQL_ENV_MYSQL_NAME"
			else export DB_NAME=`echo ${HOSTNAME//./_} | cut -c 1-16` && wps_mysql_create
			fi
		fi
	fi
		

# ENV.
# ---------------------------------------------------------------------------------


	if [[  -n $MEMCACHED_PORT  ]]; then
	export WPS_MEMCACHED=`echo $MEMCACHED_PORT | cut -d/ -f3`
	export WP_MEMCACHED_HOST=`echo $WPS_MEMCACHED | cut -d: -f1`
	export WP_MEMCACHED_PORT=`echo $WPS_MEMCACHED | cut -d: -f2`
	fi
	
	if [[  -n $REDIS_PORT  ]]; then
	export WPS_REDIS=`echo $REDIS_PORT | cut -d/ -f3`
	export WP_REDIS_HOST=`echo $WPS_REDIS | cut -d: -f1`
	export WP_REDIS_PORT=`echo $WPS_REDIS | cut -d: -f2`
	fi
	
	if [[  $WP_SSL == 'true'  ]];
	then export WP_HOME="https://${HOSTNAME}"
	else export WP_HOME="http://${HOSTNAME}"
	fi
	
	export WP_SITEURL="${WP_HOME}/wp"
	export WPS_PASSWORD="`openssl rand 12 -hex`"
	export HOME="/home/wordpress"
	export VISUAL="nano"
	
	export AUTH_KEY="`openssl rand 48 -base64`"
	export SECURE_AUTH_KEY="`openssl rand 48 -base64`"
	export LOGGED_IN_KEY="`openssl rand 48 -base64`"
	export NONCE_KEY="`openssl rand 48 -base64`"
	export AUTH_SALT="`openssl rand 48 -base64`"
	export SECURE_AUTH_SALT="`openssl rand 48 -base64`"
	export LOGGED_IN_SALT="`openssl rand 48 -base64`"
	export NONCE_SALT="`openssl rand 48 -base64`"

# 	export WPM_ENV_HTTP_SHA1="`echo -ne "$WPS_PASSWORD" | sha1sum | awk '{print $1}'`"
# 	echo -e "$user:`openssl passwd -crypt $WPS_PASSWORD`\n" > $home/.htpasswd

	echo -e "set \$MYSQL_HOST $DB_HOST;" >  $home/.adminer
	echo -e "set \$MYSQL_NAME $DB_NAME;" >> $home/.adminer
	echo -e "set \$MYSQL_USER $DB_USER;" >> $home/.adminer

	echo '' > /etc/.env && env | grep = >> /etc/.env


# SUPERVISOR
# ---------------------------------------------------------------------------------
	
	cat /wps/etc/supervisord.conf \
	| sed -e "s/example.com/$HOSTNAME/g" \
	| sed -e "s/WPS_PASSWORD/$WPS_PASSWORD/g" \
	> /etc/supervisord.conf && chmod 644 /etc/supervisord.conf


# ---------------------------------------------------------------------------------

	# hide "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php

	echo -e "$(date +%Y-%m-%d\ %T) environment setup completed." >> $home/log/wps-install.log
}
