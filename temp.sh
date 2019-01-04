
screenwidth=800
Foo()
{
    offset=$((screenwidth*$2+$1+3))
	dumpFile='/sdcard/coc/scr.dump'
	stringZ=$(dd if=$dumpFile bs=4 count=1 skip=$offset 2>/sdcard/result.txt| hd | grep " ")
    pixelParts[1]=""
	pixelParts[2]=""
	pixelPartsIndex=0
	for word in $stringZ
	do
		pixelParts[pixelPartsIndex]=$word
		pixelPartsIndex=$pixelPartsIndex+1
	done 
    red=${pixelParts[1]}
    green=${pixelParts[2]}
    blue=${pixelParts[3]}
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

