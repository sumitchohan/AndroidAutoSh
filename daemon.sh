heartBeatDelay=60
while [ 1 -le 2 ]
do
    curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/ping.sh -o ping.sh 
    source ping.sh
	sleep $heartBeatDelay
done
