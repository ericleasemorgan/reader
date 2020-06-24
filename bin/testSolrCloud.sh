while read host; do
	echo "$host"
	result=`wget $host | head -1`
	if (echo $result | grep conected 1>/dev/null 2>&1);
	then
			echo success
	else
			echo failure
	fi
done </export/coredir/solrCloudHostlist.txt