curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/Battle.config -o Battle.config
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/BuilderHome.config -o BuilderHome.config
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/ConnectionLost.config -o ConnectionLost.config
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/Home.config -o Home.config
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/do.sh -o do.sh
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/quick_attack_1 -o quick_attack_1
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/quick_attack_2 -o quick_attack_2
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/quick_attack_loose -o quick_attack_loose
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/scr.conf -o scr.conf
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/util.sh -o util.sh 
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/daemon.sh -o daemon.sh 
curl -s -k https://raw.githubusercontent.com/sumitchohan/AndroidAutoSh/master/ping.sh -o ping.sh 
source do.sh

		curl -d "ON" -X POST https://kvdb.io/Y7SPweN4icfQxaCSmuJAuu/key1 -k -s
StartThread
#Start