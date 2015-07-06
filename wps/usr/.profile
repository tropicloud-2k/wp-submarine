env='/home/wordpress/.env'

for var in `cat $env`; do 

	key=`echo $var | cut -d= -f1`
	val=`echo $var | cut -d= -f2`
	
	if [[  $key == *'-'*  ]]; then /bin/true
	elif [[  $key == *'.'*  ]]; then /bin/true
	else export "$key"="$val"
	fi
	
# 	case $key in
# 		*-*) /bin/false;;
# 		*.*) /bin/false;;
# 		*) export "$key"="$val";;
# 	esac
	
done