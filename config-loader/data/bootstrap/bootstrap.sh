#!/usr/bin/env bash


ETCD="http://etcd:2379/v2/keys"
cd /bootstrap
curl  -X DELETE "$ETCD/controller?recursive=true"
curl  -X DELETE "$ETCD/general?recursive=true"
curl  -X DELETE "$ETCD/compute?recursive=true"

for d in $(ls --ignore="*.sh" ./)
do
    for file in $(ls $d/*)
    do

        while read line
        do
	        key=`echo $line | awk -F"=" '{print $1}'`
		value=`echo $line | awk -F"=" '{print $2}'`
                echo "$key" | grep -i "general\|controller\|compute" >> /dev/null
	        if [[ $? -eq 0 ]];then # If is a valid key, we put in our etcd
		        curl -fs -X PUT "$ETCD/$key" -d value="$value"
		else #If is another word that we dont want, we dont do nothin
			break
		fi
        done < $file
    done
done
