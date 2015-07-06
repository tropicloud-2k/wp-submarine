env='/home/wordpress/.env'

for var in `cat $env`; do 

	key=`echo $var | cut -d= -f1`
	val=`echo $var | cut -d= -f2`
	
	if [[  $key == *'-'*  ]]; then /bin/true
	elif [[  $key == *'.'*  ]]; then /bin/true
	else export "$key"="$val"
	fi

done

if [[  `id -u` == 0  ]];
then export HOME="/root"
else export HOME="$home"
fi
