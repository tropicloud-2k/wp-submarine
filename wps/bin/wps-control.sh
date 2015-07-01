
# START
# ---------------------------------------------------------------------------------

wps_start() { 

	wps_check

	if [[  -z $2  ]]; then WPS_PROG="all"; else WPS_PROG="$2"; fi

	wps_header "Starting $WPS_PROG"
	wps_links && echo ""
	
	if [[  -f /tmp/supervisord.pid  ]]; then
		supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF start $WPS_PROG
	else wps_chmod && exec supervisord -n -c $SUPERVISORD_CONF
	fi
}


# STOP
# ---------------------------------------------------------------------------------

wps_stop() { 
	
	if [[  -z $2  ]]; then WPS_PROG="all"; else WPS_PROG="$2"; fi
	
	wps_header "Stopping $WPS_PROG"

	if [[  -f /tmp/supervisord.pid  ]]; then
		supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF stop $WPS_PROG		
	fi
	echo ""
}


# RESTART
# ---------------------------------------------------------------------------------

wps_restart() { 
	
	if [[  -z $2  ]]; then WPS_PROG="all"; else WPS_PROG="$2"; fi
	
	wps_header "Restarting $WPS_PROG"

	if [[  -f /tmp/supervisord.pid  ]]; then
		supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF restart $WPS_PROG
	else wps_chmod && exec supervisord -n -c $SUPERVISORD_CONF
	fi
	echo ""
}


# RELOAD
# ---------------------------------------------------------------------------------

wps_reload() { 
	
	wps_header "Reloading supervisord"

	if [[  -f /tmp/supervisord.pid  ]];
	then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF reload
	fi
	echo ""
}


# SHUTDOWN
# ---------------------------------------------------------------------------------

wps_shutdown() { 
	
	wps_header "Shutting down!"

	if [[  -f /tmp/supervisord.pid  ]];
	then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF shutdown
	fi
	echo ""
}


# STATUS
# ---------------------------------------------------------------------------------

wps_status() { 
	
	wps_header "Status"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF status all
		else supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF status $2
		fi
	
	fi
	echo ""
}


# LOG
# ---------------------------------------------------------------------------------

wps_log() { 
	
	wps_header "Log"
	
	if [[  -f /tmp/supervisord.pid  ]];
	then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF maintail
	fi
	echo ""
}


# PS
# ---------------------------------------------------------------------------------

wps_ps() { 
	
	wps_header "Container processes"

	ps auxf
	echo ""
}


# LOGIN
# ---------------------------------------------------------------------------------

wps_login() { 
	
	wps_header "\033[0mLogged in as \033[1;37m$user\033[0m"

	su -l $user
}


# ROOT
# ---------------------------------------------------------------------------------

wps_root() { 
	
	wps_header "\033[0mLogged in as \033[1;37mroot\033[0m"

	su -l root
}
