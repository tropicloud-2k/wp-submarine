
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
		supervisor \
		libmemcached \
		bash curl git nano sudo
	                 
	rm -rf /var/cache/apk/*
	rm -rf /var/lib/apt/lists/*
	
	# ADMINER
	mkdir -p /usr/local/adminer
	curl -sL http://www.adminer.org/latest-en.php > /usr/local/adminer/index.php
	
	# COMPOSER
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
	
	# PREDIS
	pear channel-discover pear.nrk.io
	pear install nrk/Predis
	
	# WP-CLI
	curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
	
	# WP-SUBMARINE
	adduser -D -G nginx -s /bin/sh -u 1000 -h $home $user

	cp -R /wps/usr/* $home

	cp /wps/usr/.profile /root/.profile
	cp /wps/usr/.profile $home/.profile

	logs_dir="msmtp nginx php supervisor wps"
	for d in $logs_dir; do
		mkdir -p $home/logs/$d
	done	

	ln -s /wps/wps.sh /usr/local/bin/wps
	chmod +x /usr/local/bin/wps

	wps_header "Done!"
}

