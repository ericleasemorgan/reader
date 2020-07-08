while read host; do
	echo "$host"
	result=`wget -qO- http://$host:8983/solr | head -1`
	if (echo $result | grep html 1>/dev/null 2>&1);
	then
			echo success
	else
			echo failure
		echo response: $result
	fi
done </export/coredir/solrCloudHostlist.txt
