
# CHECK
# ---------------------------------------------------------------------------------

wps_check() {
	case "$HOSTNAME" in
		*.*) wps_true;;
		*) wps_false;;
	esac
}

wps_true() {
	if [[  -f /etc/.env  ]]; then /bin/true; else wps_env; fi
	if [[  $WPS_MYSQL == '127.0.0.1:3306'  ]]; then wps_mysql_setup; fi	
	if [[  -d $www  ]]; then /bin/true; else wps_setup; fi
}

wps_false() {
	wps_header "(error) hostname is not set!"
	echo -e "\033[1;31m  Use the \033[1;37m-h\033[1;31m flag to set the hostname (domain)\n
\033[0m  Ex: docker run -P -h example.com -d tropicloud/wp-micro \n
\033[0m  Aborting script...\n\n"
	exit 1;
}


# HEADER
# ---------------------------------------------------------------------------------

wps_header() {
	echo -e "\033[0;30m
-----------------------------------------------------
\033[0;34m  (wps)\033[0m | \033[1;37m$1\033[0;30m
-----------------------------------------------------
\033[0m"
}


# LINKS
# ---------------------------------------------------------------------------------

wps_links() {

	if [[  -n $MYSQL_PORT  ]];
	then echo -e "\033[1;32m  •\033[0;37m MySQL\033[0m -> `echo $WPS_MYSQL`"
	else echo -e "\033[1;31m  •\033[0;37m MySQL\033[0m (not linked)"
	fi	

	if [[  -n $REDIS_PORT  ]];
	then echo -e "\033[1;32m  •\033[0;37m Redis\033[0m -> `echo $WPS_REDIS`"		
	else echo -e "\033[1;31m  •\033[0;37m Redis\033[0m (not linked)"
	fi		

	if [[  -n $MEMCACHED_PORT  ]];
	then echo -e "\033[1;32m  •\033[0;37m Memcached\033[0m -> `echo $WPS_MEMCACHED`"
	else echo -e "\033[1;31m  •\033[0;37m Memcached\033[0m (not linked)"
	fi
}


# VERSION
# ---------------------------------------------------------------------------------

wps_version(){

	LOCK_VERSION=`cat $www/composer.json | grep 'johnpbloch/wordpress' | cut -d: -f2`
	
	if [[  ! -z $WP_VERSION  ]];
	then sed -i "s/$LOCK_VERSION/\"$WP_VERSION\"/g" $www/composer.json && su -l $user -c "cd $www && composer update"
	fi
}


# CHMOD
# ---------------------------------------------------------------------------------

wps_chmod() { 

	chown -R $user:nginx $home
		
	find $home -type f -exec chmod 644 {} \;
	find $home -type d -exec chmod 755 {} \;
	
	touch /var/log/nginx/error.log
	chown $user:nginx /var/log/nginx/error.log
	
}

# ADMINER
# ---------------------------------------------------------------------------------

wps_adminer() { 

	wps_header "Adminer (mysql admin)"

	echo -e "  Password: $DB_PASSWORD\n"
	php -S 0.0.0.0:8080 -t /usr/local/adminer
}
