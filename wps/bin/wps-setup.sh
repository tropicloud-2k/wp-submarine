
wps_setup() {
		
	find $conf -type f | xargs sed -i "s|example.com|$HOSTNAME|g"

	if [[  ! -f $home/.env  ]]; then wps_env; fi
	if [[  $WP_SSL == 'true'  ]]; then wps_ssl; fi
	if [[  $WPS_MYSQL == '127.0.0.1:3306'  ]]; then wps_mysql; fi
	
	sed -i "s/WPS_PASSWORD/$WPS_PASSWORD/g" $conf/supervisor/supervisord.conf
	echo "sendmail_path = /usr/bin/msmtp -t" > /etc/php/conf.d/sendmail.ini

	# WORDPRESS
	# ---------------------------------------------------------------------------------
	
	wps_header "Installing WordPress"
	
	su -l $user -c "git clone $WP_REPO $www" && wps_version
	su -l $user -c "cd $www && composer install"

	ln -s $home/.env $www/.env
	ln -s $conf/smtp/msmtprc /etc/msmtprc

	wps_wp_install > $home/logs/wps/wp-install.log 2>&1 & 			
		
	echo -n "Initializing..."
	while ! wps_wp_status true; do echo -n '.'; sleep 1; done
	echo -n " done.\n"
	
	# -----------------------------------------------------------------------------	

	# fix "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php

	echo -e "`date +%Y-%m-%d\ %T` WordPress setup completed." >> $home/logs/wps/install.log	
}
