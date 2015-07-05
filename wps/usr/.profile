
env='/home/wordpress/.env'

for var in `cat $env`; do 

	key=`echo $var | cut -d= -f1`
	val=`echo $var | cut -d= -f2`
	
	case $key in
		*-*) /bin/false;;
		*.*) /bin/false;;
		*) export $var;;
	esac

done
