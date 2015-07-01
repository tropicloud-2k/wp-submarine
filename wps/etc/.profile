
env='/home/wordpress/www/.env'

if [[  -f $env  ]]; then
for var in `cat $env`; do 
	export $var
done
fi
