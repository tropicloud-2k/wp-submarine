
# DB CREATE
# ---------------------------------------------------------------------------------

mysql_wait() {

	echo -ne "\nWaiting mysql server..."
	while ! mysqladmin ping -h "$DB_HOST" --silent; do
		echo -n '.' && sleep 1; 
	done && echo -ne " done.\n"
}

mysql_create_link() {

	mysql_wait
	
	mysql -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -h $DB_HOST -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"
 	mysql -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -h $DB_HOST -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
 	mysql -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -h $DB_HOST -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' WITH GRANT OPTION"
	mysql -u root -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -h $DB_HOST -e "FLUSH PRIVILEGES"
}

mysql_create_local() {
	
	mysql_wait
	
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME"
 	mysql -u root -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD'"
 	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION"
	mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
	mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
	mysql -u root -e "DROP DATABASE test"
	mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
}

# DB INSTALL
# ---------------------------------------------------------------------------------

wps_mysql_install() {

	wps_header "Installing MariaDB"
	
	apk add mariadb --update
	rm -rf /var/cache/apk/*
	rm -rf /var/lib/apt/lists/*
	
	sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf
	mv $conf/supervisor/init.d/mariadb.txt $conf/supervisor/init.d/mariadb.ini
	
	mysql_install_db --user=mysql > /dev/null 2>&1
	mysqld_safe > /dev/null 2>&1 &
	mysql_create_local
	mysqladmin -u root shutdown
	
	# -----------------------------------------------------------------------------	

	echo -e "`date +%Y-%m-%d\ %T` MySQL setup completed." >> $home/logs/wps/install.log	
}
