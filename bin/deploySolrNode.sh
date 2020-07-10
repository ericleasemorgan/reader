#!/usr/bin/env bash
set -x
set -e
echo "Hello, World!"
hostname=`hostname`
echo $hostname
hostnumber=${hostname:5:2}
echo hostnumber=$hostnumber
rm -fr solr*
wget http://apache.mirrors.hoobly.com/lucene/solr/8.5.2/solr-8.5.2.tgz -O solr-8.5.2.tgz
tar --overwrite -zxf solr*tgz
solrDirectory=`find . -maxdepth 1 -type d -name "solr*"`
echo solrDirectory=$solrDirectory
cd $solrDirectory
#sed -i.bak 's|<dataDir>${solr.data.dir:}</dataDir>|<dataDir>/data</dataDir>|' $solrDirectory/server/solr/configsets/_default/conf/solrconfig.xml
sed -i.bak 's|#SOLR_JAVA_MEM="-Xms512m -Xmx512m"|SOLR_JAVA_MEM="-Xms8g -Xmx8g"|' bin/solr.in.sh

    mkdir -p /export/solr/node$hostnumber/configsets/cord/conf
    cp server/solr/configsets/_default/conf/solrconfig.xml /export/solr/node$hostnumber/configsets/cord/conf/
	cp /export/coredir/conf/DIHconfigfile.xml /export/solr/node$hostnumber/configsets/cord/conf/
	sed -i.bak "s|<dataDir>/data</dataDir>|<dataDir>/export/solr/node$hostnumber/data</dataDir>|" /export/solr/node$hostnumber/configsets/cord/conf/solrconfig.xml
	sed -i.bak "s|  <!-- SearchHandler|  <lib dir=\"\${solr.install.dir:/home/ralphlevan/solr-8.5.2}/dist/\" regex=\"solr-dataimporthandler-.*\.jar\"/>\n  <requestHandler class=\"solr.DataImportHandler\" name=\"/dataimport\">\n    <lst name=\"defaults\">\n    <str name=\"config\">DIHconfigfile.xml</str>\n  </lst>\n</requestHandler>\n  <!-- SearchHandler|" /export/solr/node$hostnumber/configsets/cord/conf/solrconfig.xml
	cp /export/coredir/conf/cord-managed-schema /export/solr/node$hostnumber/configsets/cord/conf/managed-schema
	cp -rp server/solr/configsets/_default/conf/lang/ /export/solr/node$hostnumber/configsets/cord/conf/
	cp  server/solr/configsets/_default/conf/*.txt /export/solr/node$hostnumber/configsets/cord/conf/
    mkdir -p /export/solr/node$hostnumber/data
	cp server/solr/solr.xml /export/solr/node$hostnumber/data

wget https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.30.1/sqlite-jdbc-3.30.1.jar -O server/solr-webapp/webapp/WEB-INF/lib/sqlite-jdbc-3.30.1.jar
#mv Solr-LCCN-plugin*.jar $solrDirectory/server/solr-webapp/webapp/WEB-INF/lib
cd ..


#only the first three hosts get zookeepers
if [ $hostnumber -lt 4 ]; then
	rm -fr apache-zookeeper*
	wget http://apache.mirrors.hoobly.com/zookeeper/zookeeper-3.6.1/apache-zookeeper-3.6.1-bin.tar.gz -O apache-zookeeper-3.6.1-bin.tar.gz
    tar --overwrite -zxf apache-zookeeper*tar.gz
    zookeeperDirectory=`find . -maxdepth 1 -type d -name "apache-zookeeper*"`
    echo zookeeperDirectory=$zookeeperDirectory
    if [ ! -d $zookeeperDirectory/data ]; then
        mkdir $zookeeperDirectory/data
    fi
    echo $hostnumber>$zookeeperDirectory/data/myid
    mv $zookeeperDirectory/conf/zoo_sample.cfg $zookeeperDirectory/conf/zoo.cfg
    sed -i.bak "s|dataDir=/tmp/zookeeper|dataDir=/home/ralphlevan/$zookeeperDirectory/data\nserver.1=solr-01:2888:3888\nserver.2=solr-02:2888:3888\nserver.3=solr-03:2888:3888|" $zookeeperDirectory/conf/zoo.cfg
fi

