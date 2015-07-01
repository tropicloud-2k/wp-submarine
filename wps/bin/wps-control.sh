
# START
# ---------------------------------------------------------------------------------

wps_start() { 

	wps_check
	wps_header "Start"
	wps_links && echo ""
	
	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF start all
		else supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF start $2
		fi

	else wps_chmod && exec supervisord -n -c $SUPERVISORD_CONF
	fi
}


# STOP
# ---------------------------------------------------------------------------------

wps_stop() { 
	
	wps_header "Stop"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF stop all
		else supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF stop $2
		fi
	
	fi
	echo ""
}


# RESTART
# ---------------------------------------------------------------------------------

wps_restart() { 
	
	wps_header "Restart"

	if [[  -f /tmp/supervisord.pid  ]]; then
	
		if [[  -z $2  ]];
		then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF restart all
		else supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF restart $2
		fi
		
	else wps_chmod && exec supervisord -n -c $SUPERVISORD_CONF
	fi
	echo ""
}


# RELOAD
# ---------------------------------------------------------------------------------

wps_reload() { 
	
	wps_header "Reload"

	if [[  -f /tmp/supervisord.pid  ]];
	then supervisorctl -u $user -p $WPS_PASSWORD -c $SUPERVISORD_CONF reload
	fi
	echo ""
}


# SHUTDOWN
# ---------------------------------------------------------------------------------

wps_shutdown() { 
	
	wps_header "Shutdown"

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
	
	wps_header "Container Processes"

	ps auxf
	echo ""
}


# LOGIN
# ---------------------------------------------------------------------------------

wps_login() { 
	
	wps_header "\033[0mLogged as \033[1;37m$user\033[0m"

	su -l $user
}


# ROOT
# ---------------------------------------------------------------------------------

wps_root() { 
	
	wps_header "\033[0mLogged as \033[1;37mroot\033[0m"

	su -l root
}
