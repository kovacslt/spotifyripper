#!/bin/bash

metadata=0
variant="" 
lasttime=$(date +"%s");
dbus-monitor "path=/org/mpris/MediaPlayer2,member=PropertiesChanged"|while read line
do

  col=$(echo "$line" | awk -F '"' '{print $2}')
  col2=$(echo "$line" | awk -F ' ' '{print $3}')

  if [[ "$col" == "org.mpris.MediaPlayer2.Player" ]]; then
    curtime=$(date +"%s")
    deltat=$(($curtime - $lasttime))
    if [[ "$deltat" -ge 10 ]]; then 
      metadata=1
      variant=""
      echo "__SWITCH__"
     lasttime=$curtime
    fi
      elif (($metadata)); then
        if [[ -n $(echo "$line"|grep "dict entry") ]]; then
        variant=""
      elif [[ -n $variant ]] && [[ $variant != 0 ]]; then
      if [[ -n $col ]]; then
        simplevariant=$(echo "$variant" | cut -d: -f2)
        echo "$simplevariant=$col"
        variant=0
      fi
      if [[ -n $col2 ]] ; then
        simplevariant2=$(echo "$variant" | cut -d: -f2)
        if [[ $simplevariant2 == "trackNumber" ]]; then
            col2=$(printf %02d $col2) 
            #added trailing zero to track number below 10; results like: Tracknumber=03 Tracknumber=07 Tracknumber=12 etc..
            echo "$simplevariant2=$col2"
        fi
      fi 

    elif [[ -n $col ]]; then
      variant="$col"
     # echo "variant = $col"
    fi
  fi
done
