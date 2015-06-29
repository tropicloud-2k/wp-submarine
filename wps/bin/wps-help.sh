
# HELP
# ---------------------------------------------------------------------------------

wps_help() { 

	wps_header "Help"

	echo "
  HOW TO USE:
  
  wps start                 # Start all processes
  wps start <name>          # Start a specific process
  wps stop                  # Stop all processes
  wps stop <name>           # Stop a specific process
  wps status                # Get status for all processes
  wps status <name>         # Get status for a single process
  wps restart               # Restart all processes
  wps restart <name>        # Restart a specific process
  wps reload                # Restart Supervisord
  wps shutdown              # Stop the container
  wps ps                    # List all container processes
  wps log                   # Display last 1600 *bytes* of main log file
  wps login                 # Login as wordpress user
  wps root                  # Login as root

----------------------------------------------------  

"
}