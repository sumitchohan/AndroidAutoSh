cd /sdcard/coc
#screenWidth="$(wm size | cut -d'x' -f 1 | cut -d':' -f 2 |sed -e 's/^[[:space:]]*//')"
screenwidth=800
Dump()
{
	#screenWidth="$(wm size | cut -d'x' -f 1 | cut -d':' -f 2 |sed -e 's/^[[:space:]]*//')"
	echo "$screenWidth">/sdcard/coc/screenwidth.dat
	screencap /sdcard/coc/scr.dump
	#split -b 640000 scr.dump

}  
Log()
{
	 echo "$(date) $1" >>/sdcard/coc/logs_$(date +%Y%m%d).txt
	 #echo "$(date) $1"
}

Log1()
{
	 echo "$(date) $1" >>/sdcard/coc/logs1_$(date +%Y%m%d).txt
	 #echo "$(date) $1"
}

Tap()
{
	temp=$1
	temp1=$((800-$1))
	
	input tap $2 $temp1
	#Tapf $1 $2
}
Swipe()
{

}
SendMessage()
{
	echo "SendMessage - $1"
}
Mid()
{
    echo "$1" > /sdcard/input
    substringZ=$(dd if=/sdcard/input ibs=1 skip=$2 count=$3 2> /sdcard/results)
    echo $substringZ
}
Pixel()
{ 
	IFS=" "
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
ProcessStateActionInternal()
{
	name="#$1|"
	IFS="|"
	data=$(cat scr.conf | grep $name)
	set -A parts $data
	name=${parts[0]}
	pointsData=${parts[1]}
	actions=${parts[2]}
	#Log "action - $actions"
	#Log "name - $name"
	#Log "pointsData - $pointsData"
	if [ "$2" = "match" ]
	then
		result="n"
		IFS=";"
		set -A points $pointsData
		for pixelData in "${points[@]}"
		do
			IFS=","
			set -A pixelDetails $pixelData
			pix=$(Pixel ${pixelDetails[1]} ${pixelDetails[2]})
			#rh=$(echo $pix | cut -c1-2)
			#gh=$(echo $pix | cut -c3-4)
			#bh=$(echo $pix | cut -c5-6)

			rh=$(Mid $pix 0 2)
			gh=$(Mid $pix 2 2)
			bh=$(Mid $pix 4 2)
			r=$((16#$rh))
			g=$((16#$gh))
			b=$((16#$bh))
			s=$(($(Diff $r ${pixelDetails[3]}) + $(Diff $g ${pixelDetails[4]}) + $(Diff $b ${pixelDetails[5]}) ))
			#s=$((($r - ${pixelDetails[3]})*($r - ${pixelDetails[3]}) + ($g - ${pixelDetails[4]})*($g - ${pixelDetails[4]}) + ($b - ${pixelDetails[5]})*($b - ${pixelDetails[5]})))
			tolerance=0
			if [ ${pixelDetails[0]} = "a"  ]
			then
				tolerance=20
			fi

			if [ $s -le $tolerance ]
			then
				result="y"
			else
				result="n"
				break
			fi
		done
		echo "$result"
	else
		if [ "$2" = "act" ]
		then
			IFS=";"
			set -A actions $actions
			for action in "${actions[@]}"
			do
				IFS=","
				set -A actionDetails $action
				if [ "${actionDetails[0]}" = "$3" ]
				then
					#command=""
					#commandPartIndex=0
					#for commandPart in "${actionDetails[@]}"
					#do
					#	if [ "$commandPartIndex" -eq "1" ]
					#	then
					#		command="$commandPart"
					#	fi
					#	if [ "$commandPartIndex" -gt "1" ]
					#	then
					#		command="$command $commandPart"
					#	fi
					#	(( commandPartIndex++ ))
					#done
					##$command
					#echo "command-$command--"
					#"$command"

					if [ ${actionDetails[1]} = "Tap" ]
					then
						Tap ${actionDetails[2]} ${actionDetails[3]}
					else
						if [ ${actionDetails[1]} = "Swipe" ]
						then
							Swipe ${actionDetails[2]} ${actionDetails[3]}  ${actionDetails[4]}  ${actionDetails[5]}  ${actionDetails[6]}
						else
							Tap ${actionDetails[1]} ${actionDetails[2]}
						fi
					fi
				fi
			done
		fi
	fi
}

MatchState()
{
	ProcessStateActionInternal $1 "match"
}

Act()
{
	Log "Act $1 $2"
	ProcessStateActionInternal $1 "act"	$2
}
 



WaitFor()
{
	#WaitFor stateName "skipState1,skipState2"
	result="n"
	retryIndex=1
	retryCount=$3
	retryDelay=1
	error="y"
	while [ $retryIndex -le $retryCount ]
	do
	Dump
	isbreak="n";
	Log "waiting for $1"
	matched=$(MatchState $1)
	if [ "$matched" = "y" ]
	then
		Log "Matched $1"
		error="n"
		result="y"
		break
	else
		Log "No match $1"
		IFS=","
		set -A skipScreens $2
		for skipScreen in "${skipScreens[@]}"
		do
			Log "skip check $skipScreen"
			skipMatched=$(MatchState $skipScreen)
			if [ "$skipMatched" = "y" ]
			then
				Log "skipping $skipScreen"
				if [ "$skipScreen" = "BuilderHome" ]
				then
					Zoom
					sleep 4
				fi
				Act $skipScreen "Skip"
			fi
		done
		if [ "$1" = "Battle" ] 
		then
			connError=$(MatchState ConnectionLost)
			if [ "$connError" = "y" ]
			then



				Tap 5 400
				Home
				


	Tap 80 50
	sleep .5
	#WaitFor "FindAMatch" "" 20
	#Act "FindAMatch" "Find"
	Tap 178 257 

		else

			isHome=$(MatchState Home)

			if [ "$isHome" = "y" ]
			then 
				 
	Tap 80 50
	sleep .5
	#WaitFor "FindAMatch" "" 20
	#Act "FindAMatch" "Find"
	Tap 178 257

			fi


			fi
		
		fi
		if [ "$1" = "Home" ] 
		then
			Tap 5 400
			Tap 65 265
			Tap 395 395
		fi
		sleep $retryDelay
	fi
	(( retryIndex++ ))
	done
	if [ "$result" = "n" ]
	then
		screencap -p "error_$1_$EPOCHREALTIME.png"

	fi
	echo "$result"
} 
Hello()
{
	echo "Hello $1"
} 

Loose()
{
	Home	
	Zoom
	Read "Home"
	trophy=$(cat ocred_Trophy.txt)
	maxTrophyCount=4300
	if [ "$1" = "1" ]
	then
		maxTrophyCount=2600
	else
		maxTrophyCount=4300
	fi
	echo "trophy -$trophy maxTrophyCount -  $maxTrophyCount"
	if [ "$trophy" -ge "$maxTrophyCount" ] 
	then
		echo "Loosing.."
		Tap 40 520
		sleep 0.1
		#ready=$(MatchPixel 551 296 64 117 09 100)
		ready="y"
		Tap 768 92
		sleep .5
		if [ "$ready" = "y" ]
		then		
			Act "Home" "Attack"
			sleep .5
			Tap 230 460 
			WaitFor "Battle" "" 120	
			SendMessage "loose"
			sleep .5
			Tap 66 530
			sleep 1
			Tap 494 416
			sleep 1
			Tap 396 540
			Loose $1
		else
			echo "not ready"
		fi
	fi
}


WaitForFile()
{ 
	timeOut=60
    while [ ! -f $1 ]; do 
			#echo $timeOut
			if [ $timeOut -lt 0 ]
			then
				break
			fi
        sleep 1; 
			(( timeOut-- ))
    done
		echo "WaitForFile - done"
}

Read()
{
    LogRemote "Read Start -  $1"
		screencap -p /sdcard/coc/scr.PNG
    rm /sdcard/coc/doneflag
		am start -n com.example.sumitchohan.utilityapp/.MainActivity
		sleep 2
    #am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action READ_IMAGE --es imagePath /sdcard/coc/scr.PNG --es configPath /sdcard/coc/$1.config --es completedFilePath /sdcard/coc/doneflag
    Tap 625 1180
		WaitForFile /sdcard/coc/doneflag
		LogRemote "Read End - $1"
		am start -n com.supercell.clashofclans/.GameApp
		sleep 2
		#am force-stop com.example.sumitchohan.utilityapp 
}
 
ReadBattleTest()
{
    LogRemote "ReadBattleTest -  Start"
		LogRemote "ReadBattleTest -  screencap - start"
		screencap -p /sdcard/coc/scr.PNG
		LogRemote "ReadBattleTest -  screencap - done"
		cp Battle.png scr.PNG
		LogRemote "ReadBattleTest -  doneflag - remove start"
    rm /sdcard/coc/doneflag
		LogRemote "ReadBattleTest -  doneflag - remove done"
    am startservice -n com.example.sumitchohan.utilityapp/.MyIntentService --es action READ_IMAGE --es imagePath /sdcard/coc/scr.PNG --es configPath /sdcard/coc/Battle.config --es completedFilePath /sdcard/coc/doneflag
   
		LogRemote "ReadBattleTest -  WaitForFile - start"
		WaitForFile /sdcard/coc/doneflag
		LogRemote "ReadBattleTest - End"
}

Zoom()
{
	 source /sdcard/coc/zoomout
	 source /sdcard/coc/zoomout
	 source /sdcard/coc/pulltopleft
	 source /sdcard/coc/pulltopleft
}
StartCOC()
{
	isCOC=$(dumpsys window windows | grep -E 'mCurrentFocus' | grep 'supercell.clashofclans')
	if [ "$isCOC" = "" ]
	then
		Log "no coc"
		am start -n com.supercell.clashofclans/.GameApp
		sleep 10
		am start -n com.supercell.clashofclans/.GameApp
		sleep 10 
	else
		Log "coc"
	fi
}
StopCOC()
{
	am force-stop com.supercell.clashofclans
	sleep 1
} 

LooseTrophies()
{
	trophy=$1
	if [ "$trophy" -ge "700" ]
	then
		Log "trophy $trophy ; loosing.."
		Loose
		WaitFor "Home" "Attacked,ConnectionLost,VersusHome,ReturnHome" 60
		#Read "Home"
		trophy=$(cat ocred_Trophy.txt)
		de=$(cat ocred_DE.txt)
		elixir=$(cat ocred_Elixir.txt)
		gems=$(cat ocred_Gems.txt)
		LooseTrophies $trophy
	fi
}
Home()
{
	StartCOC
	WaitFor "Home" "BuilderHome,ConnectionLost,ExitFullScreen" 10
	matched=$(MatchState "Home")
	if [ "$matched" = "n" ]
	then
		Log1 "Home not found. Taking snapshot and Stoping COC"
		screencap -p "error_Home_$(date +%Y%m%d).png"
		StopCOC
		Log1 "Trying Home"
		StartCOC
		WaitFor "Home" "BuilderHome,ConnectionLost" 30
		matched=$(MatchState "Home")
		echo "$matched"
	fi	
} 
 
ShouldAttack()
{
	result="n"
	if [ "$playernotinleague" = "y" ]
	then
	if [ "$1" = "1" ]
	then
		if  [ "$elixir" -ge "600000" ] || [ "$eg" -ge "1000000" ] || [ "$de" -ge "4000" ]
		then
			result="y"
		fi 
		if  [ "$elixir" -ge "900000" ] || [ "$eg" -ge "1800000" ] || [ "$de" -ge "7000" ]
		then 
			result="y"
		fi
	else
		if  [ "$elixir" -ge "500000" ] || [ "$eg" -ge "1000000" ] || [ "$de" -ge "4500" ]
		then
			result="y"
		fi 
		if  [ "$de" -ge "5500" ]
		then
			result="y"
		fi 
	fi 
	else
	if [ "$1" = "1" ]
	then
		if  [ "$elixir" -ge "600000" ] || [ "$eg" -ge "1000000" ] || [ "$de" -ge "4000" ]
		then
			result="y"
		fi 
		if  [ "$elixir" -ge "900000" ] || [ "$eg" -ge "1800000" ] || [ "$de" -ge "7000" ]
		then 
			result="y"
		fi
	else
		if  [ "$elixir" -ge "700000" ] || [ "$eg" -ge "1400000" ] || [ "$de" -ge "7000" ]
		then
			result="y"
		fi 
		if  [ "$de" -ge "7000" ]
		then
			result="y"
		fi 
	fi 
	fi
	Log "Should Attack - $1 $elixir $eg $isth10 $result"
	echo $result
}
maxWaitCount=30
Attack()
{
	Log1 "Attack Start $1"
	previosLoot="";

	am force-stop com.example.sumitchohan.utilityapp
	TouchRec attack
	sleep .5
	#WaitFor "FindAMatch" "" 20
	#Act "FindAMatch" "Find"
	TouchRec findamatch
	battleFound=$(WaitFor "Battle" "" 20)
	if [ "$battleFound" = "y" ]
	then
		#Zoom		
		Log1 "Battle Found $1"
		attacked="n"
		while [ "$attacked" = "n" ]
		do
			Log1 "Reading Battle $1"
			if [ $(MatchPixel 774 33 93 95 97 100) = "y" ] && [ $(MatchPixel 774 35 93 95 97 100) = "y" ] 
			then
				echo "player not in league"
				Log1 "Player not in league"
				playernotinleague="y"
				Read "Battle"			
				de=$(cat ocred_DE.txt)
				elixir=$(cat ocred_Elixir.txt)
				gold=$(cat ocred_Gold.txt) 
				win=$(cat ocred_Win.txt)
				loose=$(cat ocred_Loose.txt) 
				th10="n"
				eg=$((gold+elixir))
				#isth10=$(echo $th10| cut -d'_' -f 1)
				Log1 "elixir - $elixir , gold - $gold , de - $de , th10 - $th10 , playernotinleague - $playernotinleague"
			else				
				echo "player in league"
				Log1 "Player in league"
				playernotinleague="n"
				#Read "Battle"			
				#de=$(cat ocred_DE.txt)
				#elixir=$(cat ocred_Elixir.txt)
				#gold=$(cat ocred_Gold.txt) 
				#win=$(cat ocred_Win.txt)
				#loose=$(cat ocred_Loose.txt) 
				de=0
				elixir=0
				gold=0
				win=0
				loose=0
				th10="n"
				isth10="n"
				eg=0
				Log1 "elixir - $elixir , gold - $gold , de - $de , th10 - $th10, playernotinleague- $playernotinleague"
			fi
			#SendMessage "snapshot.sh"
			shouldAttack=$(ShouldAttack $1)
			echo "ShouldAttack $shouldAttack $1 $th10 $elixir $gold"
			LogRemote "ShouldAttack $shouldAttack $1 $elixir $gold $de" 
			loot="$elixir$gold$de" 
			loose="n"
			if [ "$shouldAttack" = "y" ] 
			then
				Zoom
				Zoom 
				echo "ready to attack"
				LogRemote "Attacking"
				QuickAttack $1
				LogRemote "Attack done!"
				waitCount=$maxWaitCount
				break
			else
				if [ "$shouldLoose" = "y" ]
				echo "looseCount - $looseCount"
				then
					if [ "$looseCount" -gt "0" ]
					then
						Zoom
						Zoom
						echo "loosing"
						LooseAttack
						(( looseCount-- ))
						loose="y"
						Tap 80 50
						sleep .5 
						Tap 178 257
					fi
				fi
			fi 
			Log "not attacking"
			echo "not attacking"
			#Act "Battle" "Next"
			if [ "$loose" = "n" ]
			then
				TouchRec next
				if [ "$playernotinleague" = "y" ]
				then
					if [ "$loot" = "$previosLoot" ] 
					then
						LogRemote "same as previous loot"
						NextBattle
					else
						previosLoot=$loot
					fi
				fi
			fi
			battleFound=$(WaitFor "Battle" "" 20)
			if [ "$battleFound" = "n" ]
			then
				waitCount=1
				LogRemote "$1_Battle not found. Break"
				UploadScrLog
				#curl -p --insecure  "ftp://ftp.chauhansumit.5gbfree.com/" --user "user@chauhansumit.5gbfree.com:Password123" -T "$fileName" --ftp-create-dirs
				break
			fi 
			Log "loot - de $de elixir $elixir gold $gold eg $eg"
			echo "loot - de $de elixir $elixir gold $gold eg $eg win $win loose $loose th10 - $th10"			
		done
	else
		waitCount=1
		LogRemote "$1_Battle not found. Break"
		UploadScrLog
				#curl -p --insecure  "ftp://ftp.chauhansumit.5gbfree.com/" --user "user@chauhansumit.5gbfree.com:Password123" -T "$fileName" --ftp-create-dirs
				break
	fi
} 

UploadScrLog()
{

				fileName="error_file_$1_$EPOCHREALTIME.png"
				logFileName="logs_$(date +%Y%m%d).txt"
				newLogFileName="logs_$1_$EPOCHREALTIME.txt"
				#cp $logFileName $newLogFileName
				#screencap -p "$fileName"
				#UploadFile "$fileName" "$fileName"
				#UploadFile "$newLogFileName" "$newLogFileName"
				#rm $newLogFileName
}
UploadFile()
{
curl -X POST https://content.dropboxapi.com/2/files/upload --header "Authorization: Bearer xTLrxttvDkAAAAAAAAAAD--BthwJpER4ml0TyCeQo_0NzcWzPXXYqLgn1fk3Tc-r" --header "Dropbox-API-Arg: {\"path\": \"/coc/$2\",\"mode\": \"add\",\"autorename\": true,\"mute\": false}" --header "Content-Type: application/octet-stream" --data-binary "@$1" --insecure
}



LooseAttack()
{
	Tap 65 220
Touch tl_0
Tap 169 85
Tap 320 750
Tap 135 640

	

}
AddTs()
{
while read data; do
	printf "$EPOCHREALTIME $data\n"
done
}

CaptureZoomEvents()
{
	getevent | AddTs > events.log & PID1=$!
	input tap 43 158
	sleep 4
	kill $PID1
}
#touchDevice=$(getevent -pl 2>&1 | sed -n '/^add/{h}/ABS_MT_TOUCH/{x;s/[^/]*//p}')
Tapf()
{
	SendMessage "tap.sh $1 $2"
	# # # #approximate tap for bluestack
	# # # # x=$(($1*1000/49))
	# # # # y=$(($2*2000/55)) /dev/input/event1

	# # # #echo "$x $y"
	# sendevent /dev/input/event1 0 0 0
	# sendevent /dev/input/event1 3 53 $1
	# sendevent /dev/input/event1 3 54 $2
	# sendevent /dev/input/event1 0 2 0
	# sendevent /dev/input/event1 0 0 0
	# sendevent /dev/input/event1 0 2 0
	# sendevent /dev/input/event1 0 0 0
	# sleep 0.001
}
DeployStart()
{
	Tapf 40 70
}
Deploy()
{
	Tapf 40 160
	sleep 20
}
DeployEnd()
{
	Tapf 40 70
	Tapf 40 70
}
 


Diff()
{
  if [ $1 -le $2 ]
  then
    echo $(($2-$1))
  else
    echo $(($1-$2))
  fi
}
MatchPixel() #x y r g b delta
{
  pix=$(Pixel $1 $2)
  
  rh=$(Mid $pix 0 2)
	gh=$(Mid $pix 2 2)
  bh=$(Mid $pix 4 2)
  r=$((16#$rh))
  g=$((16#$gh))
  b=$((16#$bh))
  #echo "$r $g $b"
  delta=$(($(Diff $3 $r)+$(Diff $4 $g)+$(Diff $5 $b)))
  #echo $tolerance
  if [ $6 -le $delta ]
  then
    result="n"
  else
    result="y"
  fi
  echo $result
}
IsReadyForAttack()
{
	Dump	
    #if [ $(MatchPixel 631 143 64 116 09 100) = "y" ] #&& [ $(MatchPixel 551 296 64 117 09 100) = "y" ]
    if [ $(MatchPixel 640 721 232 232 224 50) = "y" ] #&& [ $(MatchPixel 551 296 64 117 09 100) = "y" ]
    then		
		echo "y"
	else 
		echo "n"
	fi
}
Donate()
{
  y=90
  x=342
  while [ $y -le 600 ]
  do
    #Pixel $x $y
    isGreen=$(MatchPixel x y 171 191 79 100)
    if [ "$isGreen" = "y" ]
    then
      echo "match $x $y"
      y1=$y
      while [ $y1 -ge 1 ]
      do
        isGray=$(MatchPixel x y1 68 68 64 1)
        if [ "$isGray" = "y" ]
        then
          ReadDonation $x $y1
          #input swipe $x $((y1+5)) $x 572 1000
          #input tap $x 572
          #sleep 10
          break
        fi
        y1=$((y1-1))
      done
      y=$((y+60))
    fi
    y=$((y+10))
  done
}
 
 
QuickAttack()
{
	if [ "$1" = "2" ]
	then
		source quick_attack_2
	else
		source quick_attack_1
	fi
}

SwitchID()
{
    Log1 "ID switching to $1"
    Tap 190 1240 
    sleep 1
	Tap 200 750 
    sleep 10
    Tap 500 970
    sleep 1
    Tap 296 792
	sleep 10
	Tap 60 440  
    sleep 10
	if [ "$1" = "1" ]
	then
		Tap 340 560 #ID1
	else
		Tap 440 560 #ID2
	fi
	WaitFor "Home" "" 10 
} 
maxTrophy=7000
shouldLoose="n"
looseCount=0
failedCount=0
Run()
{
	failedCount=0
	LogRemote "$1_Starting"
	Log1 "Starting Run.. $1" 
	shouldLoose="n"
	looseCount=0
	Init
	StopCOC
	#am start -n com.x0.strai.frep/.FingerActivity
	StartCOC	
	Log1 "Trying Home"
	Home
	#SwitchID $1
	Zoom	
	Log1 "Reached Home"	


	#Read "Home"

	#	trophy=$(cat ocred_Trophy.txt)
	#	de=$(cat ocred_DE.txt)
	#	gold=$(cat ocred_Gold.txt)
	#	elixir=$(cat ocred_Elixir.txt)
	#	gems=$(cat ocred_Gems.txt)

	#LogRemote "T - $trophy G - $gold E - $elixir D - $de"

	if [ "$trophy" -gt "$maxTrophy" ]
	then
		shouldLoose="y"
		looseCount=6
	fi


	LogRemote "trophy - $trophy maxTrophy - $maxTrophy shouldLoose-$shouldLoose looseCount-$looseCount"
	#SwitchID $1 
	#Loose $1
	#quickTrainYPos=805
	#if [ "$1" = "2" ]
	#then
	#	quickTrainYPos=997
	#fi
	TouchRec menu
	sleep 0.5
	Log1 "IsReadyForAttack $1 .. taking snapshot"	
	#SendMessage "snapshot.sh"
	ready=$(IsReadyForAttack)	
	LogRemote "$1_Ready - $ready"
	if [ "$ready" = "y" ]
	then
		#Tap 697 $quickTrainYPos
		TouchRec quicktrain
		sleep 0.5
		TouchRec train1
		TouchRec menuclose
		Attack $1
		sleep 60
		StopCOC
		Home
		Zoom 
		Tap 180 50
		sleep 0.5
		Tap 697 997
		sleep 0.5
		Tap 410 1085
        Tap 700 800
        Tap 300 250
		Tap 700 1130
		sleep 1
		StopCOC 
	else
		echo "not ready"	
		LogRemote "Not Ready $1 .."	
		waitCount=$maxWaitCount
		TouchRec quicktrain
		sleep 0.5
		TouchRec train1
		TouchRec menuclose
		#sleep .5

		#Tap 697 997
		#sleep 1
		#Tap 410 1085
		#sleep 1
		#Tap 410 1085
		#sleep 1
		#Tap 700 1130
		#StopCOC


		StopCOC
	fi
	LogRemote "$1_Done"

	 
}

Init()
{
	input keyevent 3 
	sleep 1
	Dump
	isScreenOff=$(MatchPixel 100 100 0 0 0 1)
	if [ "$isScreenOff" = "y" ]
	then
		input keyevent 26
	fi 
	input keyevent 3 
	input swipe 400 750 400 100
	input keyevent 3 

}
isTroopPresent="y"
Touch()
{
	if [ "$isTroopPresent" = "y" ]
	then
    	dd if=/sdcard/coc/gestures/tap_$1.rec of=/dev/input/event3 2>/sdcard/results.txt
	fi
}


PlayRec()
{
	if [ "$isTroopPresent" = "y" ]
	then
    	dd if=/sdcard/coc/gestures/gesture$1.rec of=/dev/input/event3 2>/sdcard/results.txt
	fi
}


SelectTroop()
{
	isTroopPresent="y"
}

DeployRage1()
{
	Tap 323 476
	Tap 450 550
	Tap 530 690
}

DeployRage2()
{
	Tap 255 632
	Tap 385 770 
}


DeployTL()
{
Touch tl_0
Touch tl_9
Touch tl_1
Touch tl_8
Touch tl_2
Touch tl_7
Touch tl_3
Touch tl_4
Touch tl_5
Touch tl_6
}

DeployTLRB()
{
Touch tl_0
Touch tl_5
Touch tl_9
Touch tr_5
Touch tr_9
Touch br_3
Touch bl_3 
Touch tl_3
Touch tl_7
Touch tr_3
Touch tr_7
Touch br_2
Touch bl_2
}


DeployTR()
{
Touch tr_0
Touch tr_1
Touch tr_2
Touch tr_3
Touch tr_4
Touch tr_5
Touch tr_6
Touch tr_7
Touch tr_8
Touch tr_9

}

DeployBL()
{
Touch bl_0
Touch bl_1
Touch bl_2
Touch bl_3 

}
DeployBR()
{
Touch br_0
Touch br_1
Touch br_2
Touch br_3 
}

Deploy()
{
	if [ "$isTroopPresent" = "y" ]
	then
		Tap $1 $2
	fi 
}
waitCounter=0
StartThread()
{

error="y"
waitCount=$maxWaitCount
waitCounter=$waitCount
heartBeatDelay=30
while [ 1 -le 2 ]
do
	switch=$(curl http://timus.freeasphost.net/KeyValue.aspx?key=action -k -s)
	if [ "$switch" = "ON" ]
	then
		LogRemote "switch - $switch counter-$waitCounter" "y"
		echo "On"
		if [ "$waitCounter" -ge 0 ]
		then
			echo "waitCounter - $waitCounter"
			waitCounter=$((waitCounter-1))
			sleep $heartBeatDelay
		else 	
			echo "running..."
			Exec
			waitCounter=$waitCount
		fi
	elif [ "$switch" = "STOPPED" ]
	then
		LogRemote "switch - $switch counter-$waitCounter" "y"
		waitCounter=$waitCount
		echo "Stopped. Doing Nothing"
		sleep $heartBeatDelay
	elif [ "$switch" = "FILE" ]
	then
		echo "executing file"
		curl -s -k https://raw.githubusercontent.com/sumitchohan/sumitchohan.github.io/master/sh/run.sh -o file.sh
		source file.sh
		curl -d "ON" -X POST http://timus.freeasphost.net/KeyValue.aspx?key=action -k -s
		
		waitCounter=$waitCount
		sleep $heartBeatDelay
	elif [ "$switch" = "START" ]
	then
		curl -d "ON" -X POST http://timus.freeasphost.net/KeyValue.aspx?key=action -k -s
		Exec
		waitCounter=$waitCount
	else
		sleep $heartBeatDelay
	fi
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
Exec()
{
	#LogRemote "exec-running 1"
	#Run 1
	LogRemote "exec-running 2"
	Run 2
}


LogRemote()
{ 
	headerlog=""
	dt=$(date +%H_%M_%S);
	if [ "$2" = "y" ] 
	then
		headerlog="$dt - $1;"
	else
		echo "$dt - $1;$(cat log_remote)">log_remote
		dd if=log_remote of=log_remote_head ibs=1 skip=0 count=4000 2>/sdcard/results.txt
		cp log_remote_head log_remote
	fi
	#http://timus.freeasphost.net/KeyValue.aspx?key=actionLog
	curl -d "$headerlog$(cat log_remote)" http://timus.freeasphost.net/KeyValue.aspx?key=actionLog -s 
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

QuickTap()
{

}

Choose2()
{
	QuickTap 99 339
}

Choose1()
{
	QuickTap 99 339
}

Choose3()
{
	QuickTap 99 339
}

Choose4()
{
	QuickTap 90 499
}

TouchRec()
{
	dd if=/sdcard/coc/gestures/$1 of=/dev/input/event3 2>/sdcard/results.txt
}
NextBattle()
{
	TouchRec next
	TouchRec end1
	TouchRec end2
	sleep 5
	TouchRec attack
	TouchRec findamatch
}
DeployRageSpell1()
{
	TouchRec choose5 
	TouchRec s1
	TouchRec s2
	TouchRec s3
	TouchRec choose6
	TouchRec s1
	TouchRec s2
	TouchRec s3
	TouchRec choose5 
	TouchRec choose7
	TouchRec s1
	TouchRec s2
	TouchRec s3
	TouchRec choose5 
	TouchRec choose8
	TouchRec s1
	TouchRec s2
	TouchRec s3
	TouchRec choose9
	TouchRec s1
	TouchRec s3
}
DeployRageSpell2()
{
	TouchRec choose5
	TouchRec s4
	TouchRec s5 
	TouchRec choose6
	TouchRec s4
	TouchRec s5 
	TouchRec choose5 
	TouchRec choose7
	TouchRec s4
	TouchRec s5 
	TouchRec choose5 
	TouchRec choose8
	TouchRec s4
	TouchRec s5 
	TouchRec choose9
	TouchRec s4
	TouchRec s5 
}