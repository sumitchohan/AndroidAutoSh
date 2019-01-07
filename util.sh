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
    rm /sdcard/coc/doneflag
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action READ_IMAGE --es imagePath /sdcard/coc/scr.PNG --es configPath /sdcard/coc/$1.config --es completedFilePath /sdcard/coc/doneflag
    WaitForFile /sdcard/coc/doneflag
}

GetKeyValue()
{
    while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    done < "$1"
}
 

GetFileSize()
{ 
    rm /sdcard/coc/doneflag
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action FILE_SIZE --es filepath $1 --es completedFilePath /sdcard/coc/doneflag --es outFilePath /sdcard/coc/filesize
    WaitForFile /sdcard/coc/doneflag
    filesize=$(cat /sdcard/coc/filesize)
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


inputCommandByteSize=24
Record()
{   
    echo "" >/sdcard/recsize1
    echo "" >/sdcard/rec1
    rm /sdcard/rec1
    touch /sdcard/rec1
    #CaptureFileSize /sdcard/rec1 /sdcard/recsize1  & PIDCAP=$!
    echo $PIDCAP
    dd if=/dev/input/event3 of=/sdcard/rec1 bs=$inputCommandByteSize & PIDDD=$!
    echo $PIDDD
    echo "Recording.. Hit enter twice to stop"
    read
    #kill $PIDCAP  
    kill $PIDDD  
    ExtractClicks $1
}


PreparePlayCommand() 
{ 
    gesture="gesture$1"
    GetFileSize /sdcard/rec1 
    recFileSize=$filesize
    recLineCounts=$((recFileSize/$inputCommandByteSize))
    recLineIndex=0
    gesturePartIndex=0
    startBytes=$(dd if=/sdcard/rec1  ibs=1 skip=0 count=1 | hd)  
    offset=0 
    touch /sdcard/$gesture
    #echo "delay=\${1:-0.1}" > /sdcard/$gesture
    while [ $recLineIndex -lt $recLineCounts ]
    do
        skip=$((recLineIndex*inputCommandByteSize))
        startBytesThis=$(dd if=/sdcard/rec1  ibs=1 skip=$skip count=1 | hd)   
        if [ ! "$startBytesThis" = "$startBytes" ] || [ $recLineIndex = $((recLineCounts-1)) ]
        then    
            count=$((skip-offset))
            if [ $recLineIndex = $((recLineCounts-1)) ] 
            then
                count=$((count+inputCommandByteSize))
            fi
            dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$offset count=$count
            echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event3">>/sdcard/$gesture
            echo "sleep 0.001">>/sdcard/$gesture
            gesturePartIndex=$((gesturePartIndex+1))
            offset=$skip
            startBytes=$startBytesThis
        fi
        recLineIndex=$((recLineIndex + 1))
    done
}


ExtractClicks() 
{ 
    gesture="gesture$1"
    GetFileSize /sdcard/rec1 
    recFileSize=$filesize
    recLineCounts=$((recFileSize/$inputCommandByteSize))
    recLineIndex=0
    gesturePartIndex=0
    seperator1=$(dd if=coc/seperator ibs=1 skip=20 count=4 2>/sdcard/results.txt| hd)  
    seperator2=$(dd if=coc/seperator ibs=1 skip=35 count=13 2>/sdcard/results.txt| hd)  
    offset=0 
    echo "" >  /sdcard/$gesture
    rm /sdcard/$gesture
    touch /sdcard/$gesture
    previousseperator=""
    #echo "delay=\${1:-0.1}" > /sdcard/$gesture
    while [ $recLineIndex -lt $recLineCounts ]
    do
        skip=$((recLineIndex*inputCommandByteSize))
        endBytes=$(dd if=/sdcard/rec1  ibs=1 skip=$((skip+inputCommandByteSize-13)) count=13 2>/sdcard/results.txt| hd)   

        echo "seperator-$seperator ; endBytes - $endBytes"
        if [ "$seperator2" = "$endBytes" ] && [ "$seperator1" = "$previousseperator" ]
        then    
            echo "same"
            count=$((skip+inputCommandByteSize -offset))
            
            skipcount=$offset
            takecount=$count
            if [ ! $skipcount = 0 ]
            then
                skipcount=$((skipcount+inputCommandByteSize))
                takecount=$((count-inputCommandByteSize))
            fi

            dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$skipcount count=$takecount 2>/sdcard/results.txt
            

            echo "dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$skipcount count=$takecount 2>/sdcard/results.txt" 
            echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event3 2>/sdcard/results.txt">>/sdcard/$gesture
            #echo "sleep 0.001">>/sdcard/$gesture
            gesturePartIndex=$((gesturePartIndex+1))
            offset=$skip
            startBytes=$startBytesThis
        else
            echo "not same"
        fi
        previousseperator=$(dd if=/sdcard/rec1  ibs=1 skip=$((skip+inputCommandByteSize-4)) count=4 2>/sdcard/results.txt| hd)  
        recLineIndex=$((recLineIndex + 1))
    done
}




ExtractGestures() 
{ 
    gesture="gesture$1"
    GetFileSize /sdcard/rec1 
    recFileSize=$filesize
    recLineCounts=$((recFileSize/$inputCommandByteSize))
    recLineIndex=0
    gesturePartIndex=0
    seperator1=$(dd if=coc/seperator ibs=1 skip=20 count=4 2>/sdcard/results.txt| hd)  
    seperator2=$(dd if=coc/seperator ibs=1 skip=35 count=13 2>/sdcard/results.txt| hd)  
    offset=0 
    echo "" >  /sdcard/$gesture
    rm /sdcard/$gesture
    touch /sdcard/$gesture
    previousseperator=""
    #echo "delay=\${1:-0.1}" > /sdcard/$gesture
    while [ $recLineIndex -lt $recLineCounts ]
    do
        skip=$((recLineIndex*inputCommandByteSize))
        endBytes=$(dd if=/sdcard/rec1  ibs=1 skip=$((skip+inputCommandByteSize-13)) count=13  2>/sdcard/results.txt| hd)   

        echo "seperator-$seperator ; endBytes - $endBytes"
        if [ "$seperator2" = "$endBytes" ] #&& [ "$seperator1" = "$previousseperator" ]
        then    
            echo "same"
            count=$((skip+inputCommandByteSize -offset))


            
            skipcount=$offset
            takecount=$count
            if [ ! $skipcount = 0 ]
            then
                skipcount=$((skipcount+inputCommandByteSize))
                takecount=$((count-inputCommandByteSize))
            fi



            dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$skipcount count=$takecount 2>/sdcard/results.txt
            echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event3 2>/sdcard/results.txt">>/sdcard/$gesture
            #echo "sleep 0.001">>/sdcard/$gesture
            gesturePartIndex=$((gesturePartIndex+1))
            offset=$skip
            startBytes=$startBytesThis
        else
            echo "not same"
        fi
        #previousseperator=$(dd if=/sdcard/rec1  ibs=1 skip=$((skip+inputCommandByteSize-4)) count=4 | hd)  
        recLineIndex=$((recLineIndex + 1))
    done
}


PreparePlayCommand3() 
{ 
    gesture="gesturecc"
    recFileSize=$(stat /sdcard/rec1 | grep Size: | tr ' ' '\n' | grep Size -A1 | tail -n 1)
    recLineCounts=$((recFileSize/$inputCommandByteSize))
    recLineIndex=0
    gesturePartIndex=0
    startBytes=$(dd if=/sdcard/rec1  ibs=1 skip=0 count=1 | od)  
    offset=0 
    echo "" > /sdcard/$gesture
    while [ $recLineIndex -lt $recLineCounts ]
    do
        skip=$((recLineIndex*inputCommandByteSize))
        startBytesThis=$(dd if=/sdcard/rec1  ibs=1 skip=$skip count=1 | od)   
        if [ "a" = "a" ] || [ $recLineIndex = $((recLineCounts-1)) ]
        then    
            count=$((skip-offset))
            if [ $recLineIndex = $((recLineCounts-1)) ] 
            then
                count=$((count+inputCommandByteSize))
            fi
            dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$offset count=$count
            echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event1">>/sdcard/$gesture 
            gesturePartIndex=$((gesturePartIndex+1))
            offset=$skip
            startBytes=$startBytesThis
        fi
        recLineIndex=$((recLineIndex + 1))
    done
}
PreparePlayCommand1() 
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
            if [ $time_diff -ge 400 ] && [ $time_diff -le 100000 ]
            then
                echo "sleep $((time_diff/1000)).$((time_diff%1000))"
                echo "sleep $((time_diff/1000)).$((time_diff%1000))">>/sdcard/$gesture
            fi

        fi  
        if [ $time_diff -ge 400 ]
        then 
            echo "dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$size count=$size_d"
            dd if=/sdcard/rec1 of=/sdcard/$gesture$gesturePartIndex.rec ibs=1 skip=$size count=$size_d
            echo "dd if=/sdcard/$gesture$gesturePartIndex.rec of=/dev/input/event1">>/sdcard/$gesture
            echo "bytes -  $size_d"
            s=$s1
            ms=$ms1
            size=$size1
            gesturePartIndex=$((gesturePartIndex+1))
        fi
	
    done < /sdcard/recsize1

}
Play()
{
    gesture="gesture$1"
    source /sdcard/$gesture
}

Mid()
{
    substringZ=$(echo $1 | dd ibs=1 skip=$2 count=$3)
    echo $substringZ
}

screenwidth=800
Foo()
{
    offset=$((screenwidth*$2+$1+3))
	dumpFile='/sdcard/coc/scr.dump'
	stringZ=$(dd if=$dumpFile bs=4 count=1 skip=$offset 2>/sdcard/result.txt| hd | grep " ")
    echo "$stringZ"
    pixelParts[1]=""
	pixelParts[2]=""
	pixelPartsIndex=0
	for word in $stringZ
	do
		pixelParts[pixelPartsIndex]=$word
		pixelPartsIndex=$pixelPartsIndex+1
	done
	part1d=$((8#${pixelParts[1]}))
	typeset -i16 part1h=part1d
	part2d=$((8#${pixelParts[2]}))
	typeset -i16 part2h=part2d
	#red=$(echo $part1h | cut -c6-7)
	echo $part1h
	red=$(echo $part1h|dd ibs=1 skip=5 count=2)
	#green=$(echo $part1h | cut -c4-5)
	green=$(echo $part1h|dd ibs=1 skip=3 count=2)
	#blue=$(echo $part2h | cut -c6-7)
	blue=$(echo $part2h|dd ibs=1 skip=5 count=2)
	if [ "${#red}" = "1" ]
	then
		red="0$red"
	fi
	if [ "${#green}" = "1" ]
	then
		green="0$green"
	fi
	if [ "${#blue}" = "1" ]
	then
		blue="0$blue"
	fi
	rgb="$red$green$blue";
	echo $rgb;
}

