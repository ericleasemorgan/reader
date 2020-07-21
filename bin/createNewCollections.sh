#!/usr/bin/env bash
set -e
set -x
hostname=`hostname`
echo $hostname
hostnumber=${hostname:5:2}
hostlist="solr-master:2181,solr-worker:2181"
echo hostnumber=$hostnumber

#only do this on one server.  The zookeepers will pass it around
if [ $hostnumber -eq 1 ]; then
    export JAVA_HOME=/export/java
    echo "Creating Collections!"
	cd /home/ralphlevan/
    solrDirectory=`find . -maxdepth 1 -type d -name "solr*"`
    echo solrDirectory=$solrDirectory
    cd $solrDirectory
    bin/solr zk upconfig -n cord -d /export/solr/node$hostnumber/configsets/cord/conf -z $hostlist

#reinstate databases already existing on /data
#    for f in `find /export/solr/node$hostnumber/data -name index`
#    do
#        name=$(cut -d/ -f3 <<<"${f}")
#        db=$(cut -d- -f1 <<<"${name}")
#        week=$(cut -d- -f3 <<<"${name}")
#        if [[ $((CurrentWeek)) < $((week)) ]]
#        then
#            #happy new year!
#            collectionName=$db$LastYear$week
#        else
#            collectionName=$db$CurrentYear$week
#        fi
#        echo collection: $collectionName
#        echo "bin/solr create_collection -c $collectionName -n $name -shards 4 -replicationFactor 1"
#        bin/solr create_collection -c $collectionName -n $name -shards 4 -replicationFactor 1
#    done

fi

