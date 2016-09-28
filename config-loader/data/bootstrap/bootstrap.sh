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
	
	        curl -fs -X PUT "$ETCD/$key" -d value="$value"
        done < $file
    done
done
