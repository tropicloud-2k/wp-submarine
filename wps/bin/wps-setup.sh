
wps_setup() {
	
	# SYSTEM
	# -----------------------------------------------------------------------------

	cp -R /wps/usr/. $home
	
	find $conf -type f -exec sed -i "s|example.com|$WP_DOMAIN|g" {} \;

	if [[  ! -f $home/.env  ]]; then wps_env; fi
	if [[  $WP_SSL == 'true'  ]]; then wps_ssl; fi
	if [[  $WP_SQL == 'local'  ]]; then wps_mysql; fi

	sed -i "s/WPS_PASSWORD/$WPS_PASSWORD/g" $conf/supervisor/supervisord.conf
	
	wps_chmod
	
	# WORDPRESS
	# -----------------------------------------------------------------------------
	
	wps_header "Installing WordPress"
	
	su -l $user -c "git clone $WP_REPO $www" && wps_wp_version
	su -l $user -c "cd $www && composer install"
	ln -s $home/.env $www/.env

	wps_wp_install > $conf/submarine/wordpress.log 2>&1 &
	wps_wp_wait			

	# fix "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php
}

