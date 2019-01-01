Test()
{
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action ECHO --es data hello123  --es filepath /sdcard/input.png --es outputfilepath /sdcard/cropped.png
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action CROP --es filepath /sdcard/img.PNG --es outputfilepath /sdcard/img1.png --es x 5 --es y 8 --es w 50 --es h 16
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action READ_IMAGE --es imagePath /sdcard/img.PNG --es configPath /sdcard/temp.config
  
  
}


WaitForFile()
{ 
    while [ ! -f $1 ]; do 
        sleep 1; 
    done
}

Read()
{
    rm /sdcard/auto/doneflag
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action READ_IMAGE --es imagePath /sdcard/auto/scr.PNG --es configPath /sdcard/auto/$1.config --es completedFilePath /sdcard/auto/doneflag
    WaitForFile /sdcard/auto/doneflag
}

GetKeyValue()
{
    while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    done < "$1"
}
 

GetFileSize()
{
	echo $(stat $1 | grep Size: | tr ' ' '\n' | grep Size -A1 | tail -n 1)
}

CaptureFileSize()
{  
    rm $2
    touch $2
    size=0;
	while [ 1 -le 2 ]
	do
		newSize=$(stat $1 | grep Size: | tr ' ' '\n' | grep Size -A1 | tail -n 1)
        if [ size -ne newSize ]
        then
            echo "Recording  - $EPOCHREALTIME-$newSize"
            echo "$EPOCHREALTIME.$newSize">>$2
            size=$newSize
            sleep 0.005
        fi 
	done
}


Record()
{   
    echo "" >/sdcard/recsize1
    echo "" >/sdcard/rec1
    rm /sdcard/rec1
    touch /sdcard/rec1
    CaptureFileSize /sdcard/rec1 /sdcard/recsize1  & PIDCAP=$!
    echo $PIDCAP
    dd if=/dev/input/event1 of=/sdcard/rec1 bs=16 & PIDDD=$!
    echo $PIDDD
    echo "Recording.. Hit enter twice to stop"
    read
    kill $PIDCAP  
    kill $PIDDD  
    PreparePlayCommand $1
}
PreparePlayCommand() 
{
    gesture="gesture$1"
    s=0
    ms=0
    size=0
    first="y"
    gesturePartIndex=0
    rm /sdcard/$gesture

    while IFS='' read -r line || [[ -n "$line" ]]; do 
        lineParts[0]=""
	    lineParts[1]=""
	    lineParts[2]=""
	    linePartIndex=0
	    for part in  $(echo $line | tr '.' ' ')
	    do
		    lineParts[linePartIndex]=$part
		    linePartIndex=$linePartIndex+1
	    done

        s1=${lineParts[0]}
        ms1=${lineParts[1]}
        size1=${lineParts[2]} 
        size_d=$((size1-size))
        
        if [ "$first" = "y" ]
        then 
            first="n"
        else
            s_d=$((s1-s))
            ms_d=$((ms1-ms))
            ms_d_k=$((ms_d/1000))
            time_diff=$((s_d*1000+ms_d_k))
            echo "sleep $((time_diff/1000)).$((time_diff%1000))"
            echo "sleep $((time_diff/1000)).$((time_diff%1000))">>/sdcard/$gesture

        fi  
        dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$size count=$size_d
        echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event1">>/sdcard/$gesture

        echo "bytes -  $size_d"
        s=$s1
        ms=$ms1
        size=$size1
        gesturePartIndex=$((gesturePartIndex+1))
	
    done < /sdcard/recsize1

}
Play()
{
    gesture="gesture$1"
    source /sdcard/$gesture
}