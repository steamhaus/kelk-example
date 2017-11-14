#!/bin/bash
# Create the index mapping for the instance logs
echo "##############################"
echo "Create instance-logs-* index mapping"
echo "##############################"
echo ""
curl -XPUT localhost:9200/_template/template_kinesis_apache?pretty -d'
{
  "template": "instance-logs-*",
  "settings": {
    "number_of_shards": 1
  },
  "mappings": {
    "apache": {
      "_source": {
        "enabled": false
      },
      "properties": {
        "host": {"index": "analyzed", "store": "yes", "type": "string"},
        "ident": { "index": "analyzed", "store": "yes", "type": "string" },
        "authuser": { "index": "not_analyzed", "store": "yes", "type": "string" },
        "datetime": { "index": "analyzed", "store": "yes", "type": "date" ,"format" : "dd/MMM/yyyy:HH:mm:ss Z"},
        "request": { "index": "not_analyzed", "store": "yes", "type": "string" },
        "response": { "index": "not_analyzed", "store": "yes", "type": "string" },
        "bytes": { "index": "not_analyzed", "store": "yes", "type": "string" },
        "referrer": { "index": "not_analyzed", "store": "yes", "type": "string" },
        "agent": { "index": "not_analyzed", "store": "yes", "type": "string" }
      }
    }
  }
}'
echo ""
echo "##############################"
echo "Delete all indices"
echo "##############################"
echo ""
curl -XDELETE 'http://localhost:9200/_all'
echo ""
echo ""
# Create the Kibana index patterns for the 4 log types
echo "##############################"
echo "Create Kibana index patterns"
echo "##############################"
echo ""
curl -XPOST -H 'Content-Type: application/json' 'http://localhost:9200/.kibana/index-pattern/instance-logs-*' \
  -d'
{
	"title": "instance-logs-*",
	"timeFieldName": "datetime",
	"notExpandable": true
}'
curl -XPOST -H 'Content-Type: application/json' 'http://localhost:9200/.kibana/index-pattern/alb-logs-*' \
  -d'
{
	"title": "alb-logs-*",
	"timeFieldName": "timestamp",
	"notExpandable": true
}'
curl -XPOST -H 'Content-Type: application/json' 'http://localhost:9200/.kibana/index-pattern/cloudfront-logs-*' \
  -d'
{
	"title": "cloudfront-logs-*",
	"timeFieldName": "timestamp",
	"notExpandable": true
}'

curl -XPOST -H 'Content-Type: application/json' 'http://localhost:9200/.kibana/index-pattern/cloudtrail-logs-*' \
  -d'
{
	"title": "cloudtrail-logs-*",
	"timeFieldName": "eventTime",
	"notExpandable": true
}'
sleep 2
echo ""
echo ""
echo "##############################"
echo "Set default Kibana index"
echo "##############################"
echo ""
curl http://localhost:9200/_plugin/kibana/api/kibana/settings/defaultIndex \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "kbn-version: 5.5.2" \
-H "Connection: keep-alive" \
--data-binary '{"value":"instance-logs-*"}' -w "\n" --compressed
echo ""
