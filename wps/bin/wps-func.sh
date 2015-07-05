
# CHECK
# ---------------------------------------------------------------------------------

wps_check() {
  	if [[  -z $WP_DOMAIN  ]];
  	then wps_check_false
  	else wps_check_true
  	fi
}

wps_check_true() {
	if [[  -d $www  ]];
	then /bin/true
	else wps_setup
	fi
}

wps_check_false() {
	wps_header "[ERROR] WP_DOMAIN is not set!"
	echo -e "\033[1;31m  Pleae define WP_DOMAIN as an environment variable.\n
\033[0m  docker run -P -e WP_DOMAIN=\"example.com\" -d tropicloud/wp-submarine \n
\033[0m  Aborting script...\n\n"
	exit 1;
}


# HEADER
# ---------------------------------------------------------------------------------

wps_header() {
	echo -e "\033[0;30m
-----------------------------------------------------
\033[1;34m  (wp)\033[1;37mSubmarine\033[0m - $1\033[0;30m
-----------------------------------------------------
\033[0m"
}


# LINKS
# ---------------------------------------------------------------------------------

wps_links() {

	if [[  ! $WPS_MYSQL == '127.0.0.1:3306'  ]];
	then echo -e "\033[1;32m  •\033[0;37m MySQL\033[0m -> $WPS_MYSQL"
	else echo -e "\033[1;33m  •\033[0;37m MySQL\033[0m -> $WPS_MYSQL (localhost)"
	fi	
	
	if [[  ! -z $WPS_REDIS  ]];
	then echo -e "\033[1;32m  •\033[0;37m Redis\033[0m -> $WPS_REDIS"		
	else echo -e "\033[1;31m  •\033[0;37m Redis\033[0m [not connected]"
	fi		
	
	if [[  ! -z $WPS_MEMCACHED  ]];
	then echo -e "\033[1;32m  •\033[0;37m Memcached\033[0m -> $WPS_MEMCACHED"
	else echo -e "\033[1;31m  •\033[0;37m Memcached\033[0m [not connected]"
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

	sudo chown -R $user:nginx $home
	
	sudo find $home -type f -exec chmod 644 {} \;
	sudo find $home -type d -exec chmod 755 {} \;
}

# ADMINER
# ---------------------------------------------------------------------------------

wps_adminer() { 

	wps_header "Adminer (mysql admin)"

	echo -e "  Password: $DB_PASSWORD\n"
	php -S 0.0.0.0:8888 -t /usr/local/adminer
}
