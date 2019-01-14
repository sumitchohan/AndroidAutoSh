
Main()

{
    while [ 1 -le 2 ]
do
	switch=$(curl https://api.keyvalue.xyz/139afa57/mainKey -k -s)
	if [ "$switch" = "ON" ]
	then
        curl -d "OFF" -X POST https://api.keyvalue.xyz/139afa57/mainKey  -k -s  
		curl -s -k https://raw.githubusercontent.com/sumitchohan/sumitchohan.github.io/master/sh/main.sh -o file.sh
		source file.sh
        sleep 300 
	fi
done
}
