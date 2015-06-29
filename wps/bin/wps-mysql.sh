
# DB CREATE
# ---------------------------------------------------------------------------------

wps_mysql_create() {
	echo -ne "Creating mysql database..."
	mysql -u root -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h $DB_HOST -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
	mysql -u root -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h $DB_HOST -e "CREATE DATABASE $DB_NAME"
	mysql -u root -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h $DB_HOST -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' WITH GRANT OPTION"
	mysql -u root -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h $DB_HOST -e "FLUSH PRIVILEGES"
}

wps_mariadb_create() {
	mysql -u root -e "CREATE USER '$user'@'%' IDENTIFIED BY '$DB_PASSWORD'"
	mysql -u root -e "CREATE DATABASE $user"
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$user'@'%' WITH GRANT OPTION"
}

wps_mariadb_secure() {
	mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
	mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
	mysql -u root -e "DROP DATABASE test;"
	mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
}


# DB INSTALL
# ---------------------------------------------------------------------------------

wps_mysql_setup() {

	wps_header "MariaDB Setup"
	
	apk add mariadb --update
	rm -rf /var/cache/apk/*
	rm -rf /var/lib/apt/lists/*
	
	sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf
	cat /wps/etc/init.d/mariadb.ini > $home/init.d/mariadb.ini
	
	mysql_install_db --user=mysql > /dev/null 2>&1
	mysqld_safe > /dev/null 2>&1 &
	
	echo -ne "Starting mysql server..."
	while [[  ! -e /run/mysqld/mysqld.sock  ]]; do echo -n '.' && sleep 1; done && echo -ne " done.\n"
	
	echo -ne "Creating mysql database..."
	while ! wps_mariadb_create true; do echo -n '.' && sleep 1; done && echo -ne " done.\n"
	
	echo -ne "Securing mysql installation..."
	while ! wps_mariadb_secure true; do echo -n '.' && sleep 1; done && echo -ne " done.\n"
	
	echo -ne "Flushing mysql privileges..."
	while ! `mysql -u root -e "FLUSH PRIVILEGES"` true; do echo -n '.' && sleep 1; done && echo -ne " done.\n"
	
	mysqladmin -u root shutdown
	
	echo -e "$(date +%Y-%m-%d\ %T) mysql setup completed." >> $home/log/wps-install.log	
}
