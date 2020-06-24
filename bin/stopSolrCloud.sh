#!/usr/bin/env bash
set -e
echo "Hello, Solr!"
cd /home/ralphlevan/

solrDirectory=`find . -maxdepth 1 -type d -name "solr*"`
echo solrDirectory=$solrDirectory
export JAVA_HOME=/export/java
cd $solrDirectory
bin/solr stop -all

hostname=`hostname`
echo $hostname
hostnumber=${hostname:5:2}
hostlist="solr-master:2181,solr-worker:2181"
echo hostnumber=$hostnumber

if [ $hostnumber -lt 4 ]; then
    echo "Hello, Zookeeper!"
	cd /home/ralphlevan/
    zookeeperDirectory=`find . -maxdepth 1 -type d -name "apache-zookeeper*"`
    echo zookeeperDirectory=$zookeeperDirectory
    cd $zookeeperDirectory
    bin/zkServer.sh stop
fi

