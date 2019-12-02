flag1=$(curl https://kvdb.io/Y7SPweN4icfQxaCSmuJAuu/key3 -k -s)
echo "$flag1"
if [ "$flag1" = "RUN" ]
then
	dt=$(date +%H_%M_%S)
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
    source do.sh
    Start

    curl -d "ping at $dt" -X POST https://kvdb.io/Y7SPweN4icfQxaCSmuJAuu/key3 -k -s 
else
	dt=$(date +%H_%M_%S)
    curl -d "ping at $dt" -X POST https://kvdb.io/Y7SPweN4icfQxaCSmuJAuu/key3 -k -s 
fi
