#!/usr/bin/env bash
set -e
set -x

hostname=`hostname`
echo $hostname
hostnumber=${hostname:5:2}
zklist="solr-01:2181,solr-02:2181,solr-03:2181"
echo hostnumber=$hostnumber
export JAVA_HOME=/export/java

if [ $hostnumber -lt 4 ]; then
    echo "Hello, Zookeeper!"
    cd /home/ralphlevan/
    zookeeperDirectory=`find . -maxdepth 1 -type d -name "apache-zookeeper*"`
    echo zookeeperDirectory=$zookeeperDirectory
    cd $zookeeperDirectory
    bin/zkServer.sh start
fi

echo "Hello, Solr!"
cd /home/ralphlevan/
solrDirectory=`find . -maxdepth 1 -type d -name "solr*"`
echo solrDirectory=$solrDirectory
#$solrDirectory/bin/solr -c -z $zklist -s /prod/data/solr
cd $solrDirectory
#bin/solr start -c -z $zklist -s /prod/viafsolrcloud/prod/solrcloud/$solrDirectory/server/solr
#cp /prod/viafsolrcloud/prod/solrcloud/$solrDirectory/server/solr/solr.xml /data
bin/solr start -c -z $zklist -s /export/solr/node$hostnumber/data -DzkClientTimeout=600000

