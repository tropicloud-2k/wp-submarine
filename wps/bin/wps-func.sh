
# CHECK
# ---------------------------------------------------------------------------------

wps_check() {
  	if [[  -z $VIRTUAL_HOST  ]];
  	then wps_false
  	else wps_true
  	fi
}

wps_true() {
	if [[  -d $www  ]];
	then /bin/true
	else wps_setup
	fi
}

wps_false() {
	wps_header "[ERROR] Hostname is not set!"
	echo -e "\033[1;31m  Use the -h flag to set the hostname (domain)
or define it as an environment variable.\n
\033[0m  Ex: docker run -P -h example.com -d tropicloud/wp-micro
\033[0m      docker run -P -e HOSTNAME=\"example.com\" -d tropicloud/wp-micro \n
\033[0m  Aborting script...\n\n"
	exit 1;
}


# HEADER
# ---------------------------------------------------------------------------------

wps_header() {
	echo -e "\033[0;30m
-----------------------------------------------------
\033[0;34m  wp\033[0m-\033[1;37msubmarine\033[0m - $1\033[0;30m
-----------------------------------------------------
\033[0m"
}


# LINKS
# ---------------------------------------------------------------------------------

wps_links() {

	if [[  ! $WPS_MYSQL == '127.0.0.1:3306'  ]];
	then echo -e "\033[1;32m  •\033[0;37m MySQL\033[0m -> $WPS_MYSQL"
	else echo -e "\033[1;33m  •\033[0;37m MySQL\033[0m [in container]"
	fi	
	
	if [[  ! -z $WPS_REDIS  ]];
	then echo -e "\033[1;32m  •\033[0;37m Redis\033[0m -> $WPS_REDIS"		
	else echo -e "\033[1;31m  •\033[0;37m Redis\033[0m [not linked]"
	fi		
	
	if [[  ! -z $WPS_MEMCACHED  ]];
	then echo -e "\033[1;32m  •\033[0;37m Memcached\033[0m -> $WPS_MEMCACHED"
	else echo -e "\033[1;31m  •\033[0;37m Memcached\033[0m [not linked]"
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
	
}

# ADMINER
# ---------------------------------------------------------------------------------

wps_adminer() { 

	wps_header "Adminer (mysql admin)"

	echo -e "  Password: $DB_PASSWORD\n"
	php -S 0.0.0.0:8888 -t /usr/local/adminer
}
