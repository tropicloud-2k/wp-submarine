
# WPS BUILD
# ---------------------------------------------------------------------------------	

wps_build() {

	wps_header "Building image"

	apk add --update \
		mariadb-client \
		msmtp \
		nginx \
		openssl \
		php-cli \
		php-curl \
		php-fpm \
		php-gd \
		php-gettext \
		php-iconv \
		php-json \
		php-mcrypt \
		php-memcache \
		php-mysql \
		php-opcache \
		php-openssl \
		php-phar \
		php-pear \
		php-pdo \
		php-pdo_mysql \
		php-pdo_pgsql \
		php-pdo_sqlite \
		php-xml \
		php-zlib \
		php-zip \
		py-pip \
		supervisor \
		libmemcached \
		bash curl git nano sudo
	                 
	rm -rf /var/cache/apk/*
	rm -rf /var/lib/apt/lists/*
	
	# LOGS (stdout)
	pip install --upgrade pip 2>/dev/null
	pip install supervisor-stdout
	
	# ADMINER
	mkdir -p /usr/local/adminer
	curl -sL http://www.adminer.org/latest-en.php > /usr/local/adminer/index.php
	
	# COMPOSER
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
	
	# PREDIS
	pear channel-discover pear.nrk.io
	pear install nrk/Predis
	
	# MSMTP
	ln -s $conf/smtp/msmtprc /etc/msmtprc
	echo "sendmail_path = /usr/bin/msmtp -t" > /etc/php/conf.d/sendmail.ini
	
	# WP-CLI
	curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
	
	# WP-SUBMARINE
	adduser -D -G nginx -s /bin/sh -u 1000 -h $home $user
	echo "$user ALL = NOPASSWD : ALL" >> /etc/sudoers

	cp -R /wps/usr/* $home

	cp /wps/usr/.profile $home/.profile
	cp /wps/usr/.profile /root/.profile
	echo -e "export HOME=/root" >> /root/.profile

	ln -s /wps/wps.sh /usr/local/bin/wps
	chmod +x /usr/local/bin/wps

	wps_header "Done!"
}

