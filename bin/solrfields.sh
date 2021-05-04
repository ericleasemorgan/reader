 #!/bin/bash
INDEX=http://localhost:8983/solr/cord/schema

echo "adding field: carrels"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"carrels", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: authors"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"authors", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: keywords"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"keywords", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: sources"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"sources", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: urls"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"urls", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: title"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"title", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: date"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"date", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: year"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"year", "type":"pint", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: journal"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"journal", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: source"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"source", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: abstract"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"abstract", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: license"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"license", "type":"text_general", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: pdf_json"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"pdf_json", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: pmc_json"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"pmc_json", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: sha"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"sha", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: doi"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"doi", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: arxiv_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"arxiv_id", "type":"string", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: cord_uid"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"cord_uid", "type":"string", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: mag_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"mag_id", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: pmc_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"pmc_id", "type":"string", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: pubmed_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"pubmed_id", "type":"string", "multiValued":false, "stored":true}}' $INDEX
echo "adding field: who_id"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"who_id", "type":"string", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: fulltext"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"fulltext", "type":"text_general", "multiValued":false, "stored":false}}' $INDEX
echo "adding field: entity"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"entity", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding field: type"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"type", "type":"text_general", "multiValued":true, "stored":true}}' $INDEX
echo "adding facet: authors"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_authors", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: journal"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_journal", "type":"string", "multiValued":false, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: sources"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_sources", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: urls"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_urls", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: keywords"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_keywords", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: license"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_license", "type":"string", "multiValued":false, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: entity"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_entity", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding facet: type"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-field": {"name":"facet_type", "type":"string", "multiValued":true, "stored":true, "omitTermFreqAndPositions":true}}' $INDEX
echo "adding catch-all field: _text_"
curl -X POST -H 'Content-type:application/json' --data-binary '{"add-copy-field" : {"source":"*","dest":"_text_"}}' $INDEX

