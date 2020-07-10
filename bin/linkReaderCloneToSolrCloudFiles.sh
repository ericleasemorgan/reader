#!/bin/bash
echo Hi Ralph!
list="createNewCollections.sh deploySolrCloud.sh deploySolrNode.sh linkReaderCloneToSolrCloudFiles.sh startSolrCloud.sh startSolrNode.sh solrfields.sh stopSolrCloud.sh stopSolrNode.sh testSolrCloud.sh" 
for name in $list; do
    echo $name
    ln -sfn /export/solr/solr-cloud-branch/reader/bin/$name /export/coredir/
done
chmod 777 *.sh

list="cord-managed-schema DIHconfigfile.xml solrconfig.xml"
for name in $list; do
    echo $name
    ln -sfn /export/solr/solr-cloud-branch/reader/etc/$name /export/coredir/conf
done
