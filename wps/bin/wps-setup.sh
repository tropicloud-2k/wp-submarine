
wps_setup() {
		
	# MSMTP
	# ---------------------------------------------------------------------------------

	cat /wps/etc/smtp/msmtprc | sed -e "s/example.com/$HOSTNAME/g" > /etc/msmtprc
	echo "sendmail_path = /usr/bin/msmtp -t" > /etc/php/conf.d/sendmail.ini
	touch /var/log/msmtp.log
	chmod 777 /var/log/msmtp.log
	
	# NGINX
	# ---------------------------------------------------------------------------------

	cat /wps/etc/init.d/nginx.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/nginx.ini
	cat /wps/etc/nginx/nginx.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/nginx.conf
	
	if [[  $WP_SSL == 'true'  ]];
	then cat /wps/etc/nginx/wpssl.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/wordpress.conf && wps_ssl
	else cat /wps/etc/nginx/wp.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/wordpress.conf
	fi

	# PHP-FPM
	# ---------------------------------------------------------------------------------
	
	cat /wps/etc/init.d/php-fpm.ini | sed -e "s/example.com/$HOSTNAME/g" > $home/init.d/php-fpm.ini

	if [[  $(free -m | grep 'Mem' | awk '{print $2}') -gt 1800  ]];
	then cat /wps/etc/php/php-fpm.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	else cat /wps/etc/php/php-fpm-min.conf | sed -e "s/example.com/$HOSTNAME/g" > $home/conf.d/php-fpm.conf
	fi

	# SUPERVISOR
	# -----------------------------------------------------------------------------	
	
	cat /wps/etc/supervisord.conf \
	| sed -e "s/example.com/$HOSTNAME/g" \
	| sed -e "s/WPS_PASSWORD/$WPS_PASSWORD/g" \
	> $SUPERVISORD_CONF

	# WORDPRESS
	# ---------------------------------------------------------------------------------
	
	wps_header "WordPress Setup"
	
	su -l $user -c "git clone $WP_REPO $www" && wps_version
	su -l $user -c "cd $www && composer install"

	wps_wp_install > $home/log/wps/wp-install.log 2>&1 & 			
		
	echo -ne "Installing WordPress..."
	wps_wp_status() { cat $home/log/wps/wp-install.log | grep -q 'WordPress installed successfully'; }
	while ! wps_wp_status true; do echo -n '.'; sleep 1; done; echo -ne " done.\n"
	
	# -----------------------------------------------------------------------------	

	# hide "The mysql extension is deprecated and will be removed in the future: use mysqli or PDO"
	sed -i "s/define('WP_DEBUG'.*/define('WP_DEBUG', false);/g" $www/config/environments/development.php

	echo -e "`date +%Y-%m-%d\ %T` WordPress setup completed." >> $home/log/wps/install.log	
}
