

StartThread()
{
   
while [ 1 -le 2 ]
do
    echo "">>file.sh
    source file.sh
    sleep 1
done
}

Start()
{
	echo "">> thread_info
	source thread_info
	echo ""> thread_info
	StartThread &
	tid=$!
	echo "kill $tid">>thread_info
}

Tap()
{
    echo "x - $1   y - $2"
}

LogRemote()
{ 
	dt=$(date '%H_%M_%S');
	echo "$dt - $1<br>$(cat log_remote)">log_remote
	dd if=log_remote of=log_remote_head ibs=1 skip=0 count=1000 2>/sdcard/results.txt
	cp log_remote_head log_remote
	curl -d "$(cat log_remote)" -X POST https://api.keyvalue.xyz/bc4b42e6/logKey -k -s
}

Choose()
{
    if [ "$1" = "$2" ]
    then 
        Tap $3 $4
        isTroopPresent="y"
    fi
}

MapTroops()
{ 
    rm /sdcard/coc/intent_completed
    am startservice -n com.example.akshika.opencvtest/.MyIntentService --es screenImgPath scr.png --es itemImgPaths king,primo,queen,archer --es directoryPath /sdcard/coc --es resultsFilePath choose.sh --es input_offset_x 0 --es input_offset_y 0 --es input_width 125 --es input_height 1200
    WaitForFile /sdcard/coc/intent_completed
}