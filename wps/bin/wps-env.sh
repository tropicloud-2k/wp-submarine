
wps_env() {

# MYSQL 
# ---------------------------------------------------------------------------------

	if [[  -n $MYSQL  ]]; then
	
		DB_HOST=`echo $MYSQL | cut -d: -f1`
		DB_PORT=`echo $MYSQL | cut -d: -f2`
		
		if [[  -n $MYSQL_USER  ]]; then export DB_USER="$MYSQL_USER"; else export DB_USER=`echo ${HOSTNAME//./_} | cut -c 1-16`; fi
		if [[  -n $MYSQL_PASSWORD ]]; then export DB_PASSWORD="$MYSQL_PASSWORD"; else export DB_PASSWORD=`openssl rand -hex 12`; fi
		if [[  -z $MYSQL_NAME ]]; then export DB_NAME=`echo ${HOSTNAME//./_} | cut -c 1-16` && wps_mysql_create; fi

	elif [[  -z $MYSQL  ]]; then

		export DB_HOST="127.0.0.1"
		export DB_NAME="$user"
		export DB_USER="$user"
		export DB_PASSWORD=`openssl rand -hex 12`
		export MYSQL="${DB_HOST}:${DB_PORT}"
		
	fi
	

# ENV.
# ---------------------------------------------------------------------------------


	if [[  -n $MEMCACHED  ]]; then
	export WP_MEMCACHED_HOST=`echo $MEMCACHED | cut -d: -f1`
	export WP_MEMCACHED_PORT=`echo $MEMCACHED | cut -d: -f2`
	fi
	
	if [[  -n $REDIS  ]]; then
	export WP_REDIS_HOST=`echo $REDIS | cut -d: -f1`
	export WP_REDIS_PORT=`echo $REDIS | cut -d: -f2`
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
