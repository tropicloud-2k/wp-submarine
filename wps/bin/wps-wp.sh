
# WP INSTALL
# ---------------------------------------------------------------------------------

wps_wp_core() {

	cd $web	
	wp core install --url=$WP_HOME --title=$WP_TITLE --admin_name=$WP_USER --admin_email=$WP_MAIL --admin_password=$WP_PASS
	wp rewrite structure '/%postname%/'
	wps_wp_plugins
}

wps_wp_install() {
		
	if [[  -n "$WP_TITLE" && -n "$WP_USER" && -n "$WP_MAIL" && -n "$WP_PASS"  ]]; then
		if [[  -z $MYSQL_PORT  ]]; then
			mysqld_safe > /dev/null 2>&1 &
			while [[  ! -e /run/mysqld/mysqld.sock  ]]; do sleep 1; done && wps_wp_core			
			mysqladmin -u root shutdown
		else wps_wp_core
		fi
	else echo "`date +%Y-%m-%d\ %T` WordPress installed successfully." >> $home/logs/wps/wp-install.log
	fi
	exit 0;
}

wps_wp_status() {

	cat $home/logs/wps/wp-install.log 2>/dev/null | grep -q 'WordPress installed successfully'
}


# WP PLUGINS
# ---------------------------------------------------------------------------------

wps_wp_plugins() {

	if [[  ! -z $MEMCACHED_PORT  ]]; then
		wp plugin install wp-ffpc --activate
		sed -i "s/127.0.0.1:11211/$WPS_MEMCACHED/g" $home/conf.d/nginx.conf		
		curl -sL https://raw.githubusercontent.com/petermolnar/wp-ffpc/master/wp-ffpc.php \
		| sed "s/127.0.0.1:11211/$WPS_MEMCACHED/g" \
		| sed "s/'memcached'/'memcache'/g" \
		| sed "s/'pingback_header'.*/'pingback_header' => true,/g" \
		| sed "s/'response_header'.*/'response_header' => true,/g" \
		| sed "s/'generate_time'.*/'generate_time' => true,/g" \
		> $web/app/plugins/wp-ffpc/wp-ffpc.php
		echo "define('WP_CACHE', true);" >> $www/config/environments/production.php
	fi
	
	if [[  ! -z $REDIS_PORT  ]]; then
		wp plugin install redis-cache --activate
		sed -i "s/127.0.0.1:11211/$WPS_REDIS/g" $home/conf.d/nginx.conf
		echo "define('WP_REDIS_HOST', getenv('WP_REDIS_HOST'));" >> $www/config/environments/production.php
		echo "define('WP_REDIS_PORT', getenv('WP_REDIS_PORT'));" >> $www/config/environments/production.php
	fi
}

