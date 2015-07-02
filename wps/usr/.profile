
env='/home/wordpress/.env'

if [[  -f $env  ]]; then
for var in `cat $env`; do 
	export $var
done
fi
