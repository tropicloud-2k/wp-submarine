
wps_env() {

# REDIS
# ---------------------------------------------------------------------------------

	if [[  ! -z $REDIS_PORT  ]];
	then export WPS_REDIS="`echo $REDIS_PORT | cut -d/ -f3`"
	     export WP_REDIS_HOST="`echo $WPS_REDIS | cut -d: -f1`"
	     export WP_REDIS_PORT="`echo $WPS_REDIS | cut -d: -f2`"
	fi
	
# MEMCACHED
# ---------------------------------------------------------------------------------

	if [[  ! -z $MEMCACHED_PORT  ]];
	then export WPS_MEMCACHED="`echo $MEMCACHED_PORT | cut -d/ -f3`"
	     export WP_MEMCACHED_HOST="`echo $WPS_MEMCACHED | cut -d: -f1`"
	     export WP_MEMCACHED_PORT="`echo $WPS_MEMCACHED | cut -d: -f2`"
	fi
	
# MYSQL 
# ---------------------------------------------------------------------------------

	if [[ -z $DB_HOST ]] && [[ -z $DB_USER ]] && [[ -z $DB_NAME ]] && [[ -z $DB_PASSWORD ]]; then

		if [[  -z $MYSQL_PORT  ]]; then
		
			export WPS_MYSQL="127.0.0.1:3306"
			export DB_HOST="`echo $WPS_MYSQL | cut -d: -f1`"
			export DB_PORT="`echo $WPS_MYSQL | cut -d: -f2`"
			export DB_USER="`echo ${WP_DOMAIN//./_} | cut -c 1-16`"
			export DB_NAME="`echo ${WP_DOMAIN//./_} | cut -c 1-16`"
			export DB_PASSWORD="`openssl rand -hex 12`"
			export DB_PREFIX="`openssl rand -hex 3`_"
		
		elif [[  -n $MYSQL_PORT  ]]; then 
			
			export WPS_MYSQL="`echo $MYSQL_PORT | cut -d/ -f3`"
			export DB_HOST="`echo $WPS_MYSQL | cut -d: -f1`"
			export DB_PORT="`echo $WPS_MYSQL | cut -d: -f2`"
			
			if [[  -z $MYSQL_ENV_MYSQL_USER  ]];
			then export DB_USER="`echo ${WP_DOMAIN//./_} | cut -c 1-16`"
			else export DB_USER="$MYSQL_ENV_MYSQL_USER"
			fi

			if [[  -z $MYSQL_ENV_MYSQL_PASSWORD  ]];
			then export DB_PASSWORD="`openssl rand -hex 12`"
			else export DB_PASSWORD="$MYSQL_ENV_MYSQL_PASSWORD"
			fi
			
			if [[  -z $DB_PREFIX  ]];
			then export DB_PREFIX="`openssl rand -hex 3`_"
			fi

			if [[  -z $MYSQL_ENV_MYSQL_NAME  ]];
			then export DB_NAME="`echo ${WP_DOMAIN//./_} | cut -c 1-16`" && mysql_create_link
			else export DB_NAME="$MYSQL_ENV_MYSQL_NAME"
			fi						
		fi
	fi
		
# WORDPRESS
# ---------------------------------------------------------------------------------

	if [[  $WP_SSL == 'true'  ]];
	then export WP_HOME="https://${WP_DOMAIN}"
	else export WP_HOME="http://${WP_DOMAIN}"
	fi
	
	export WPS_CTL="$conf/supervisor/supervisord.conf"
	export WPS_PASSWORD="`openssl rand 12 -hex`"
	export WP_SITEURL="${WP_HOME}/wp"
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

# DUMP
# ---------------------------------------------------------------------------------
	
	echo -e "set \$DB_HOST $DB_HOST;" >> $home/.adminer
	echo -e "set \$DB_NAME $DB_NAME;" >> $home/.adminer
	echo -e "set \$DB_USER $DB_USER;" >> $home/.adminer

	echo -e "source $env\nexport HOME=$home" > $home/.profile
	echo -e "source $env\nexport HOME=/root" > /root/.profile
	
	env | grep = >> $home/.env

# ---------------------------------------------------------------------------------

	echo -e "`date +%Y-%m-%d\ %T` Environment setup completed." >> $home/logs/wps_setup.log
}
