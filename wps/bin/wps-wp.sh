
# WP INSTALL
# ---------------------------------------------------------------------------------

wps_wp_install() {
		
	export WPS_INSTALL"wordpress"

	if [[  -n "$WP_USER"  ]] && [[  -n "$WP_MAIL"  ]] && [[  -n "$WP_PASS"  ]]; then
	
		if [[  $WPS_MYSQL == '127.0.0.1:3306'  ]]; then
			mysqld_safe > /dev/null 2>&1 &
			mysql_wait && wps_wp_core			
			mysqladmin -u root shutdown
		else wps_wp_core
		fi
		
	else export WPS_INSTALL"completed"
	fi
}

wps_wp_core() {

	cd $web
	
	WP_TITLE="Another awesome WP-Submarine site"
	
	wp core install --url="$WP_HOME" --title="$WP_TITLE" --admin_name="$WP_USER" --admin_email="$WP_MAIL" --admin_password="$WP_PASS"
	wp rewrite structure '/%postname%/'
	wps_wp_plugins
	
	export WPS_INSTALL"completed"
}

wps_wp_wait() {


	echo -ne "Loading environment..."
	while [[ $WPS_INSTALL != 'completed'  ]]; do
		echo -n '.' && sleep 1
	done && echo -ne " done.\n"
}


# WP PLUGINS
# ---------------------------------------------------------------------------------

wps_wp_plugins() {

	if [[  ! -z $MEMCACHED_PORT  ]]; then
		wp plugin install wp-ffpc --activate
		sed -i "s/127.0.0.1:11211/$WPS_MEMCACHED/g" $conf/nginx/nginx.conf		
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
		sed -i "s/127.0.0.1:11211/$WPS_REDIS/g" $conf/nginx/nginx.conf
		echo "define('WP_REDIS_HOST', getenv('WP_REDIS_HOST'));" >> $www/config/environments/production.php
		echo "define('WP_REDIS_PORT', getenv('WP_REDIS_PORT'));" >> $www/config/environments/production.php
	fi
}

