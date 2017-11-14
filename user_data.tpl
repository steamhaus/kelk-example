#!/bin/bash

yum install -y httpd aws-kinesis-agent

cat << 'EOF' > /etc/aws-kinesis/agent.json
{
  "cloudwatch.emitMetrics": false,
  "kinesis.endpoint": "kinesis.eu-west-1.amazonaws.com",
  "firehose.endpoint": "firehose.eu-west-1.amazonaws.com",

  "flows": [
    {
      "filePattern": "/var/log/httpd/access_log",
      "deliveryStream": "kelk-example",
      "dataProcessingOptions": [
         {
            "optionName": "LOGTOJSON",
            "logFormat": "COMBINEDAPACHELOG"
         }
      ]
    }
  ]
}
EOF

echo 'Hello world!' > /var/www/html/index.html

chmod -R +xr /var/log/httpd/
service httpd start
service aws-kinesis-agent start
chkconfig httpd on
chkconfig aws-kinesis-agent on
