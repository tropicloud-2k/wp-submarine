
wps_setup() {
		
	if [[  ! -f $home/.env  ]]; then wps_env; fi
	if [[  $WPS_MYSQL == '127.0.0.1:3306'  ]]; then wps_mysql_setup; fi	

	# MSMTP
	# ---------------------------------------------------------------------------------

	cat /etc/wps/smtp/msmtprc | sed -e "s/example.com/$HOSTNAME/g" > /etc/msmtprc
	echo "sendmail_path = /usr/bin/msmtp -t" > /etc/php/conf.d/sendmail.ini
# 	touch /var/log/msmtp.log
# 	chmod 777 /var/log/msmtp.log
	
	# NGINX
	# ---------------------------------------------------------------------------------

	cat /etc/wps/nginx/nginx.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/nginx.conf
	cat /etc/wps/init.d/nginx.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/nginx.ini
	
	if [[  $WP_SSL == 'true'  ]];
	then cat /etc/wps/nginx/wpssl.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/wordpress.conf && wps_ssl
	else cat /etc/wps/nginx/wp.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/wordpress.conf
	fi

	# PHP-FPM
	# ---------------------------------------------------------------------------------
	
	cat /etc/wps/init.d/php-fpm.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/php-fpm.ini

	if [[  $(free -m | grep 'Mem' | awk '{print $2}') -gt 1800  ]];
	then cat /etc/wps/php/php-fpm.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	else cat /etc/wps/php/php-fpm-min.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	fi

	# SUPERVISOR
	# -----------------------------------------------------------------------------	
	
	cat /etc/wps/supervisord.conf \
	| sed -e "s/example.com/$HOSTNAME/g" \
	| sed -e "s/WPS_PASSWORD/$WPS_PASSWORD/g" \
	> $SUPERVISORD_CONF

	# WORDPRESS
	# ---------------------------------------------------------------------------------
	
	wps_header "Installing WordPress"
	
	su -l $user -c "git clone $WP_REPO $www" && wps_version
	su -l $user -c "cd $www && composer install"
	ln -s $home/.env $www/.env

	wps_wp_install > $home/log/wps/wp-install.log 2>&1 & 			
		
	echo -ne "Installing WordPress..."
	wps_wp_status() { cat $home/log/wps/wp-install.log 2>/dev/null | grep -q 'WordPress installed successfully'; }
	while ! wps_wp_status true; do echo -n '.'; sleep 1; done; echo -ne " done.\n"
	
	# -----------------------------------------------------------------------------	

	# hide "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php

	echo -e "`date +%Y-%m-%d\ %T` WordPress setup completed." >> $home/log/wps/install.log	
}
